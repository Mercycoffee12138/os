#include <slub_pmm.h>
#include <pmm.h>
#include <list.h>
#include <string.h>
#include <stdio.h>
#include <assert.h>
#include <mmu.h>

// 页到内核虚拟地址转换的辅助宏
#define page2kva(page) ((void*)(page2pa(page) + va_pa_offset))

// 全局SLUB分配器实例
struct slub_allocator slub_allocator;

// kmalloc/kfree的占位符实现（通常由系统提供）
// 这些是用于演示的简化实现
static char static_heap[PGSIZE * 16];  // 64KB静态堆用于引导
static size_t heap_used = 0;

static void *kmalloc(size_t size) {
    if (heap_used + size > sizeof(static_heap)) {
        return NULL;
    }
    void *ptr = &static_heap[heap_used];
    heap_used = ROUNDUP(heap_used + size, 8);
    return ptr;
}

static void kfree(void *ptr) {
    // 简化版 - 在真实实现中会正确管理堆
    // 为了演示目的，我们不实际释放内存
}

// 辅助函数声明
static void *get_object_from_page(struct Page *page, struct slub_cache *cache);
static void put_object_to_page(struct Page *page, void *obj, struct slub_cache *cache);
static struct Page *allocate_slab(struct slub_cache *cache);
static void free_slab(struct Page *page, struct slub_cache *cache);
static void setup_page_objects(struct Page *page, struct slub_cache *cache);

// PMM管理器接口函数

/**
 * 初始化SLUB分配器
 */
void slub_init(void) {
    // 初始化全局分配器
    memset(&slub_allocator, 0, sizeof(slub_allocator));

    // 创建按大小分类的缓存
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
        size_t size = index_to_size(i);
        char cache_name[32];
        snprintf(cache_name, sizeof(cache_name), "slub-%u", (unsigned int)size);

        struct slub_cache *cache = slub_cache_create(cache_name, size, SLUB_ALIGN);
        slub_allocator.size_caches[i] = cache;
    }

    cprintf("SLUB allocator initialized with %d size classes\n", SLUB_NUM_SIZES);
}

/**
 * 为SLUB初始化内存映射
 */
void slub_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);

    // 计算页信息数组的最大页数
    slub_allocator.max_pages = n;

    // 从内存开始处分配页信息数组
    // 这是一个简化的方法 - 在真实系统中会更复杂
    size_t info_size = n * sizeof(struct slub_page_info);
    size_t info_pages = (info_size + PGSIZE - 1) / PGSIZE;

    if (info_pages >= n) {
        panic("Not enough memory for SLUB page info array");
    }

    slub_allocator.page_infos = (struct slub_page_info *)page2kva(base);
    memset(slub_allocator.page_infos, 0, info_size);

    // 将剩余页面初始化为空闲
    struct Page *p = base + info_pages;
    for (size_t i = info_pages; i < n; i++, p++) {
        ClearPageReserved(p);
        ClearPageProperty(p);
        set_page_ref(p, 0);
    }

    cprintf("SLUB memmap initialized: %u pages, %u info pages\n", (unsigned int)n, (unsigned int)info_pages);
}

/**
 * 使用SLUB算法分配页面
 * 对于页级分配，委托给buddy系统或回退到简单分配
 */
struct Page *slub_alloc_pages(size_t n) {
    assert(n > 0);

    // 对于多页分配，使用简单的first-fit方法
    // 在真实系统中，这会委托给buddy分配器

    extern struct Page *pages;
    extern size_t npage;

    struct Page *page = NULL;
    struct Page *p = pages;

    for (size_t i = 0; i < npage; i++, p++) {
        if (PageReserved(p) || PageProperty(p)) {
            continue;
        }

        // 检查是否有足够的连续页面
        struct Page *found = p;
        size_t count = 0;
        for (size_t j = 0; j < n && (i + j) < npage; j++) {
            if (PageReserved(found + j) || PageProperty(found + j)) {
                break;
            }
            count++;
        }

        if (count >= n) {
            page = found;
            break;
        }
    }

    if (page != NULL) {
        for (size_t i = 0; i < n; i++) {
            SetPageReserved(page + i);
            set_page_ref(page + i, 1);
        }
    }

    return page;
}

/**
 * 释放页面
 */
void slub_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    assert(PageReserved(base));

    for (size_t i = 0; i < n; i++) {
        struct Page *p = base + i;
        assert(PageReserved(p));

        ClearPageReserved(p);
        ClearPageSlab(p);
        set_page_ref(p, 0);
    }
}

/**
 * 获取空闲页面数量
 */
size_t slub_nr_free_pages(void) {
    extern struct Page *pages;
    extern size_t npage;

    size_t free_pages = 0;
    for (size_t i = 0; i < npage; i++) {
        if (!PageReserved(pages + i) && !PageProperty(pages + i)) {
            free_pages++;
        }
    }

    return free_pages;
}

// SLUB Core Functions

/**
 * Create a new SLUB cache
 */
struct slub_cache *slub_cache_create(const char *name, size_t size, size_t align) {
    // Allocate cache structure from system memory
    struct slub_cache *cache = (struct slub_cache *)kmalloc(sizeof(struct slub_cache));
    if (!cache) {
        return NULL;
    }

    // Initialize cache
    memset(cache, 0, sizeof(struct slub_cache));

    // Allocate and copy name string
    size_t name_len = strlen(name) + 1;
    char *cache_name = (char *)kmalloc(name_len);
    if (cache_name) {
        strcpy(cache_name, name);
        cache->name = cache_name;
    } else {
        cache->name = "unnamed";
    }

    cache->object_size = ROUNDUP(size, align);
    cache->align = align;

    // Calculate objects per slab
    cache->objects_per_slab = (PGSIZE - sizeof(void*)) / cache->object_size;
    if (cache->objects_per_slab == 0) {
        cache->objects_per_slab = 1;
    }

    // Initialize lists
    list_init(&cache->partial_list);

    // Initialize CPU cache
    cache->cpu_cache.freelist = (void **)kmalloc(SLUB_CPU_CACHE_SIZE * sizeof(void*));
    cache->cpu_cache.avail = 0;
    cache->cpu_cache.limit = SLUB_CPU_CACHE_SIZE;
    cache->cpu_cache.page = NULL;

    return cache;
}

/**
 * Allocate object from SLUB cache
 */
void *slub_alloc(size_t size) {
    if (size == 0) return NULL;
    if (size > SLUB_MAX_SIZE) return NULL;

    // Find appropriate size class
    int index = size_to_index(size);
    if (index < 0) return NULL;

    struct slub_cache *cache = slub_allocator.size_caches[index];
    if (!cache) return NULL;

    void *obj = NULL;

    // Try CPU cache first
    if (cache->cpu_cache.avail > 0) {
        cache->cpu_cache.avail--;
        obj = cache->cpu_cache.freelist[cache->cpu_cache.avail];
        slub_allocator.cache_hits++;
        slub_allocator.total_allocs++;
        cache->nr_allocs++;
        cache->nr_free--;
        return obj;
    }

    // Try partial slab
    if (!list_empty(&cache->partial_list)) {
        list_entry_t *le = list_next(&cache->partial_list);
        // Get slub_page_info from list entry
        struct slub_page_info *info = to_struct(le, struct slub_page_info, slab_list);

        // Calculate corresponding Page from slub_page_info
        size_t info_index = info - slub_allocator.page_infos;
        struct Page *page = pages + info_index;

        obj = get_object_from_page(page, cache);
        if (obj) {
            info->inuse++;
            if (info->inuse >= info->objects) {
                // Page is full, remove from partial list
                list_del(&info->slab_list);
            }
        }
    }

    // Allocate new slab if needed
    if (!obj) {
        struct Page *page = allocate_slab(cache);
        if (page) {
            obj = get_object_from_page(page, cache);
            struct slub_page_info *info = page_to_slub_info(page);
            if (info && obj) {
                info->inuse++;
            }
        }
    }

    if (obj) {
        slub_allocator.total_allocs++;
        cache->nr_allocs++;
        cache->nr_free--;
    }

    return obj;
}

/**
 * Free object to SLUB cache
 */
void slub_free(void *ptr, size_t size) {
    if (!ptr || size == 0) return;
    if (size > SLUB_MAX_SIZE) return;

    // Find appropriate cache
    int index = size_to_index(size);
    if (index < 0) return;

    struct slub_cache *cache = slub_allocator.size_caches[index];
    if (!cache) return;

    // Try to put in CPU cache
    if (cache->cpu_cache.avail < cache->cpu_cache.limit) {
        cache->cpu_cache.freelist[cache->cpu_cache.avail] = ptr;
        cache->cpu_cache.avail++;
    } else {
        // CPU cache full, put back to page
        // For simplicity, we'll just store it in CPU cache by evicting oldest
        void *evicted = cache->cpu_cache.freelist[0];
        memmove(&cache->cpu_cache.freelist[0], &cache->cpu_cache.freelist[1],
               (cache->cpu_cache.avail - 1) * sizeof(void*));
        cache->cpu_cache.freelist[cache->cpu_cache.avail - 1] = ptr;

        // Handle evicted object (simplified)
        // In real implementation, we would put it back to the proper page
    }

    slub_allocator.total_frees++;
    cache->nr_frees++;
    cache->nr_free++;
}

// Helper function implementations

static struct Page *allocate_slab(struct slub_cache *cache) {
    struct Page *page = slub_alloc_pages(1);
    if (!page) return NULL;

    SetPageSlab(page);
    struct slub_page_info *info = page_to_slub_info(page);
    if (info) {
        info->cache = cache;
        info->objects = cache->objects_per_slab;
        info->inuse = 0;
        info->freelist = NULL;
        list_add(&cache->partial_list, &info->slab_list);

        setup_page_objects(page, cache);
    }

    cache->nr_slabs++;
    slub_allocator.nr_slabs++;

    return page;
}

static void setup_page_objects(struct Page *page, struct slub_cache *cache) {
    struct slub_page_info *info = page_to_slub_info(page);
    if (!info) return;

    void *addr = page2kva(page);
    void **freelist = &info->freelist;

    // Setup linked list of free objects
    for (unsigned int i = 0; i < cache->objects_per_slab; i++) {
        void *obj = (char*)addr + i * cache->object_size;
        *(void**)obj = *freelist;
        *freelist = obj;
    }
}

static void *get_object_from_page(struct Page *page, struct slub_cache *cache) {
    struct slub_page_info *info = page_to_slub_info(page);
    if (!info || !info->freelist) return NULL;

    void *obj = info->freelist;
    info->freelist = *(void**)obj;

    return obj;
}

static void put_object_to_page(struct Page *page, void *obj, struct slub_cache *cache) {
    struct slub_page_info *info = page_to_slub_info(page);
    if (!info) return;

    *(void**)obj = info->freelist;
    info->freelist = obj;
}

// Statistics and debug functions
void slub_print_stats(void) {
    cprintf("SLUB Allocator Statistics:\n");
    cprintf("  Total allocations: %u\n", (unsigned int)slub_allocator.total_allocs);
    cprintf("  Total frees: %u\n", (unsigned int)slub_allocator.total_frees);
    cprintf("  Cache hits: %u\n", (unsigned int)slub_allocator.cache_hits);
    cprintf("  Total slabs: %u\n", (unsigned int)slub_allocator.nr_slabs);
}

void slub_print_cache_info(struct slub_cache *cache) {
    if (!cache) return;

    cprintf("Cache %s:\n", cache->name ? cache->name : "unnamed");
    cprintf("  Object size: %u\n", (unsigned int)cache->object_size);
    cprintf("  Objects per slab: %u\n", cache->objects_per_slab);
    cprintf("  Total slabs: %u\n", (unsigned int)cache->nr_slabs);
    cprintf("  Allocations: %u\n", (unsigned int)cache->nr_allocs);
    cprintf("  Frees: %u\n", (unsigned int)cache->nr_frees);
}

// Cache destruction function
void slub_cache_destroy(struct slub_cache *cache) {
    if (!cache) return;

    // Free CPU cache freelist
    if (cache->cpu_cache.freelist) {
        kfree(cache->cpu_cache.freelist);
    }

    // In a full implementation, we would also free all slabs
    // For now, just clear the structure

    kfree(cache);
}

// Simplified check function
void slub_check(void) {
    cprintf("SLUB allocator check started\n");

    // Test all size classes
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
        size_t size = index_to_size(i);
        void *ptr = slub_alloc(size);

        if (ptr) {
            // Write test pattern
            memset(ptr, 0xAA, size);

            // Verify pattern
            char *bytes = (char*)ptr;
            for (size_t j = 0; j < size; j++) {
                assert(bytes[j] == (char)0xAA);
            }

            slub_free(ptr, size);
        }
    }

    // Basic allocation test
    void *p1 = slub_alloc(32);
    void *p2 = slub_alloc(64);
    void *p3 = slub_alloc(128);

    assert(p1 != NULL);
    assert(p2 != NULL);
    assert(p3 != NULL);
    assert(p1 != p2 && p2 != p3 && p1 != p3);

    // Free test
    slub_free(p1, 32);
    slub_free(p2, 64);
    slub_free(p3, 128);

    // Print statistics
    slub_print_stats();

    // Print cache information
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
        if (slub_allocator.size_caches[i]) {
            slub_print_cache_info(slub_allocator.size_caches[i]);
        }
    }

    cprintf("SLUB allocator check completed successfully\n");
}

// PMM Manager structure
const struct pmm_manager slub_pmm_manager = {
    .name = "slub_pmm_manager",
    .init = slub_init,
    .init_memmap = slub_init_memmap,
    .alloc_pages = slub_alloc_pages,
    .free_pages = slub_free_pages,
    .nr_free_pages = slub_nr_free_pages,
    .check = slub_check,
};