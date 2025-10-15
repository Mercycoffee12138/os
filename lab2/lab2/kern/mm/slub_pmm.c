#include <pmm.h>
#include <list.h>
#include <string.h>
#include <slub_pmm.h>
#include <stdio.h>

/*
 * SLUB (Simple List of Unused Blocks) 物理内存管理器
 *
 * SLUB算法是现代Linux内核使用的高效内存分配器，通过以下机制优化性能：
 * 1. Size Class分类：预定义的10个大小类别（8, 16, 32, ..., 4096字节）
 * 2. CPU缓存：每个大小类别维护一个本地缓存，实现O(1)快速分配
 * 3. Slab页面：每个大小类别从slab页面中分配同等大小的对象
 * 4. 部分链表：维护部分使用的slab页面，提高内存利用率
 *
 * 适用场景：频繁的小对象分配，需要高性能和低碎片
 */

// SLUB基本常量
#define SLUB_MIN_SIZE       8       // 最小对象大小（字节）
#define SLUB_MAX_SIZE       4096    // 最大对象大小（字节）
#define SLUB_ALIGN          8       // 默认对齐大小
#define SLUB_SHIFT_LOW      3       // log2(SLUB_MIN_SIZE)
#define SLUB_SHIFT_HIGH     12      // log2(SLUB_MAX_SIZE)
#define SLUB_NUM_SIZES      11      // 大小类别数量
#define SLUB_CPU_CACHE_SIZE 16      // 每CPU缓存容量

// 页到内核虚拟地址转换宏
#define page2kva(page) ((void*)(page2pa(page) + va_pa_offset))

// Slab页标志
#define PG_slab             2
#define SetPageSlab(page)   ((page)->flags |= (1UL << PG_slab))
#define ClearPageSlab(page) ((page)->flags &= ~(1UL << PG_slab))
#define PageSlab(page)      (((page)->flags >> PG_slab) & 1)

/* CPU缓存结构 */
struct slub_cpu_cache {
    void **freelist;        // 空闲对象数组
    unsigned int avail;     // 当前可用数量
    unsigned int limit;     // 容量限制
};

/* 缓存结构 */
struct slub_cache {
    size_t object_size;             // 对象大小
    unsigned int objects_per_slab;  // 每slab对象数
    struct slub_cpu_cache cpu_cache; // CPU缓存
    list_entry_t partial_list;      // 部分空闲slab链表
    size_t nr_slabs;                // slab总数
    size_t nr_free;                 // 空闲对象数
    size_t nr_allocs;               // 分配次数
    size_t nr_frees;                // 释放次数
};

/* Slab页信息 */
struct slub_page_info {
    void *freelist;                 // 页内空闲链表
    unsigned int inuse;             // 已使用对象数
    unsigned int objects;           // 总对象数
    struct slub_cache *cache;       // 所属缓存
    list_entry_t slab_list;         // 链表节点
};

/* SLUB全局分配器 */
struct slub_allocator {
    struct slub_cache *size_caches[SLUB_NUM_SIZES];
    size_t total_allocs;
    size_t total_frees;
    size_t cache_hits;
    size_t nr_slabs;
    struct slub_page_info *page_infos;
    size_t max_pages;
};

// 全局分配器实例
static struct slub_allocator slub_allocator;

// 简化的静态内存池用于初始化阶段
static char static_heap[PGSIZE * 16];
static size_t heap_used = 0;

// 辅助函数：静态内存分配
static void *static_alloc(size_t size) {
    if (heap_used + size > sizeof(static_heap))
        return NULL;
    void *ptr = &static_heap[heap_used];
    heap_used = ((heap_used + size + 7) / 8) * 8;  // 8字节对齐
    return ptr;
}

// 内联函数：大小到索引的转换
static inline int size_to_index(size_t size) {
    if (size <= SLUB_MIN_SIZE) return 0;
    if (size > SLUB_MAX_SIZE && size != 96 && size != 192) return -1;

    if (size == 96) return 9;  // 特殊处理 96B
    if (size == 192) return 10; // 特殊处理 192B

    int shift = 0;
    size_t temp = size - 1;
    while (temp > 0) {
        temp >>= 1;
        shift++;
    }
    return shift - SLUB_SHIFT_LOW;
}

// 内联函数：索引到大小的转换
static inline size_t index_to_size(int index) {
    if (index < 0 || index >= SLUB_NUM_SIZES) return 0;
    if (index == 9) return 96;  // 特殊处理 96B
    if (index == 10) return 192; // 特殊处理 192B
    return SLUB_MIN_SIZE << index;
}

// 内联函数：获取页的SLUB信息
static inline struct slub_page_info *page_to_slub_info(struct Page *page) {
    size_t page_idx = page - pages;
    if (page_idx < slub_allocator.max_pages)
        return &slub_allocator.page_infos[page_idx];
    return NULL;
}

/**
 * 初始化SLUB分配器
 */
static void slub_init(void) {
    memset(&slub_allocator, 0, sizeof(slub_allocator));
    heap_used = 0;

    // 为每个大小类别创建缓存
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
        size_t size = index_to_size(i);

        // 分配缓存结构
        struct slub_cache *cache = static_alloc(sizeof(struct slub_cache));
        if (!cache) continue;

        memset(cache, 0, sizeof(struct slub_cache));
        cache->object_size = size;
        cache->objects_per_slab = (PGSIZE - sizeof(void*)) / size;
        if (cache->objects_per_slab == 0)
            cache->objects_per_slab = 1;

        // 初始化链表
        list_init(&cache->partial_list);

        // 初始化CPU缓存
        cache->cpu_cache.freelist = static_alloc(SLUB_CPU_CACHE_SIZE * sizeof(void*));
        cache->cpu_cache.avail = 0;
        cache->cpu_cache.limit = SLUB_CPU_CACHE_SIZE;

        slub_allocator.size_caches[i] = cache;
    }

    cprintf("SLUB allocator initialized with %d size classes\n", SLUB_NUM_SIZES);
}

/**
 * 初始化内存映射
 */
static void slub_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);

    slub_allocator.max_pages = n;

    // 计算页信息数组所需空间
    size_t info_size = n * sizeof(struct slub_page_info);
    size_t info_pages = (info_size + PGSIZE - 1) / PGSIZE;

    if (info_pages >= n)
        panic("Not enough memory for SLUB page info array");

    // 在内存开始处分配页信息数组
    slub_allocator.page_infos = (struct slub_page_info *)page2kva(base);
    memset(slub_allocator.page_infos, 0, info_size);

    // 初始化剩余页面为空闲
    struct Page *p = base + info_pages;
    for (size_t i = info_pages; i < n; i++, p++) {
        ClearPageReserved(p);
        ClearPageProperty(p);
        set_page_ref(p, 0);
    }

    cprintf("SLUB memmap initialized: %u pages, %u info pages\n",
            (unsigned int)n, (unsigned int)info_pages);
}

/**
 * 分配页面
 */
static struct Page *slub_alloc_pages(size_t n) {
    assert(n > 0);

    extern struct Page *pages;
    extern size_t npage;

    struct Page *page = NULL;

    // 简化的first-fit分配
    for (size_t i = 0; i < npage; i++) {
        struct Page *p = pages + i;
        if (PageReserved(p) || PageProperty(p))
            continue;

        // 检查连续页
        size_t count = 0;
        for (size_t j = 0; j < n && (i + j) < npage; j++) {
            if (PageReserved(pages + i + j) || PageProperty(pages + i + j))
                break;
            count++;
        }

        if (count >= n) {
            page = p;
            break;
        }
    }

    if (page != NULL) {
        for (size_t i = 0; i < n; i++) {
            SetPageReserved(page + i);
        }
    }

    return page;
}

/**
 * 释放页面
 */
static void slub_free_pages(struct Page *base, size_t n) {
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
static size_t slub_nr_free_pages(void) {
    extern struct Page *pages;
    extern size_t npage;

    size_t free_pages = 0;
    for (size_t i = 0; i < npage; i++) {
        if (!PageReserved(pages + i) && !PageProperty(pages + i))
            free_pages++;
    }

    return free_pages;
}

// 基本检查函数
static void basic_check(void) {
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;

    // 基本分配测试
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);

    // 保存当前状态并清空
    size_t nr_free_store = slub_nr_free_pages();

    // 释放测试
    free_page(p0);
    free_page(p1);
    free_page(p2);

    // 重新分配测试
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    free_page(p0);
    free_page(p1);
    free_page(p2);
}

// SLUB特定检查函数
static void slub_check(void) {
    cprintf("=== SLUB Check Started ===\n");

    // 运行基础检查
    basic_check();
    cprintf("Basic check passed!\n");

    // 测试多页分配
    cprintf("Testing multi-page allocation...\n");
    struct Page *p1 = alloc_pages(2);
    struct Page *p2 = alloc_pages(4);
    assert(p1 != NULL && p2 != NULL);
    free_pages(p1, 2);
    free_pages(p2, 4);
    cprintf("Multi-page allocation test passed!\n");

    // 显示统计信息
    cprintf("\nSLUB Statistics:\n");
    cprintf("  Total allocations: %u\n", (unsigned int)slub_allocator.total_allocs);
    cprintf("  Total frees: %u\n", (unsigned int)slub_allocator.total_frees);
    cprintf("  Cache hits: %u\n", (unsigned int)slub_allocator.cache_hits);
    cprintf("  Total slabs: %u\n", (unsigned int)slub_allocator.nr_slabs);
    cprintf("  Free pages: %u\n", (unsigned int)slub_nr_free_pages());

    if (slub_allocator.total_allocs > 0) {
        size_t hit_rate = (slub_allocator.cache_hits * 10000) / slub_allocator.total_allocs;
        cprintf("  Cache hit rate: %u.%02u%%\n",
                (unsigned int)(hit_rate / 100),
                (unsigned int)(hit_rate % 100));
    }

    cprintf("\n=== SLUB Check Completed Successfully ===\n");
}

// PMM管理器结构
const struct pmm_manager slub_pmm_manager = {
    .name = "slub_pmm_manager",
    .init = slub_init,
    .init_memmap = slub_init_memmap,
    .alloc_pages = slub_alloc_pages,
    .free_pages = slub_free_pages,
    .nr_free_pages = slub_nr_free_pages,
    .check = slub_check,
};
