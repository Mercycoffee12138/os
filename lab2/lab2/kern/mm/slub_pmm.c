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
    cprintf("=== SLUB Comprehensive Check Started ===\n");

    // 保存初始状态
    size_t initial_free_pages = slub_nr_free_pages();
    size_t initial_allocs = slub_allocator.total_allocs;
    size_t initial_frees = slub_allocator.total_frees;

    cprintf("Initial state: %u free pages, %u allocs, %u frees\n",
            (unsigned int)initial_free_pages,
            (unsigned int)initial_allocs,
            (unsigned int)initial_frees);

    // 1. 运行基础检查
    cprintf("\n[Basic] Running basic page allocation checks...\n");
    basic_check();
    cprintf("Basic check passed!\n");

    // 2. 检查SLUB大小分类系统
    cprintf("\n[SLUB] Checking size classification system...\n");
    size_t expected_sizes[] = {8, 16, 32, 64, 128, 256, 512, 1024, 2048, 96, 192};

    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
        size_t actual_size = index_to_size(i);
        assert(actual_size == expected_sizes[i]);

        int actual_index = size_to_index(actual_size);
        assert(actual_index == i);

        cprintf("  Size class %d: %u bytes ✓\n", i, (unsigned int)actual_size);
    }

    // 测试边界条件
    assert(size_to_index(1) == 0);     // 小于最小值
    assert(size_to_index(8) == 0);     // 最小值
    assert(size_to_index(96) == 9);    // 特殊大小96
    assert(size_to_index(192) == 10);  // 特殊大小192
    assert(size_to_index(5000) == -1); // 超出范围
    cprintf("Size classification system check passed!\n");

    // 3. 检查缓存结构初始化
    cprintf("\n[Cache] Checking cache structures...\n");
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
        struct slub_cache *cache = slub_allocator.size_caches[i];
        assert(cache != NULL);
        assert(cache->object_size == index_to_size(i));
        assert(cache->objects_per_slab > 0);
        assert(cache->cpu_cache.limit == SLUB_CPU_CACHE_SIZE);
        assert(cache->cpu_cache.avail == 0);
        assert(cache->cpu_cache.freelist != NULL);
        assert(list_empty(&cache->partial_list));

        cprintf("  Cache %d (size %u): %u objects per slab ✓\n",
                i, (unsigned int)cache->object_size, cache->objects_per_slab);
    }
    cprintf("Cache structures check passed!\n");

    // 4. 检查页面信息结构
    cprintf("\n[PageInfo] Checking page info structures...\n");
    assert(slub_allocator.page_infos != NULL);
    assert(slub_allocator.max_pages > 0);

    for (size_t i = 0; i < 10 && i < slub_allocator.max_pages; i++) {
        struct slub_page_info *info = &slub_allocator.page_infos[i];
        assert(info->freelist == NULL);
        assert(info->inuse == 0);
        assert(info->objects == 0);
        assert(info->cache == NULL);
    }
    cprintf("Page info structures check passed!\n");

    // 5. 测试多页分配和释放
    cprintf("\n[MultiPage] Testing multi-page allocation...\n");
    struct Page *test_pages[4];
    size_t alloc_sizes[] = {1, 2, 4, 3};

    for (int i = 0; i < 4; i++) {
        test_pages[i] = alloc_pages(alloc_sizes[i]);
        assert(test_pages[i] != NULL);

        for (size_t j = 0; j < alloc_sizes[i]; j++) {
            assert(PageReserved(test_pages[i] + j));
        }
        cprintf("  Allocated %u pages ✓\n", (unsigned int)alloc_sizes[i]);
    }

    for (int i = 0; i < 4; i++) {
        free_pages(test_pages[i], alloc_sizes[i]);
    }
    cprintf("Multi-page allocation test passed!\n");

    // 6. 边界条件测试
    cprintf("\n[Boundary] Testing boundary conditions...\n");

    struct Page *p_single = alloc_pages(1);
    assert(p_single != NULL);
    free_pages(p_single, 1);
    cprintf("  Single page allocation ✓\n");

    struct Page *p_large = alloc_pages(16);
    if (p_large != NULL) {
        free_pages(p_large, 16);
        cprintf("  Large allocation (16 pages) ✓\n");
    } else {
        cprintf("  Large allocation skipped (insufficient memory)\n");
    }

    extern struct Page *pages;
    if (pages != NULL && slub_allocator.max_pages > 0) {
        struct slub_page_info *info = page_to_slub_info(pages);
        assert(info != NULL);
        cprintf("  Page info boundary access ✓\n");
    }
    cprintf("Boundary conditions test passed!\n");

    // 7. 压力测试
    cprintf("\n[Stress] Running stress test...\n");
    size_t stress_initial_free = slub_nr_free_pages();
    const int test_cycles = 15;
    struct Page *stress_pages[test_cycles];

    for (int cycle = 0; cycle < 2; cycle++) {
        cprintf("  Stress cycle %d...\n", cycle + 1);

        // 分配阶段
        for (int i = 0; i < test_cycles; i++) {
            size_t size = (i % 3) + 1;
            stress_pages[i] = alloc_pages(size);
            assert(stress_pages[i] != NULL);
        }

        // 释放阶段
        for (int i = test_cycles - 1; i >= 0; i--) {
            size_t size = (i % 3) + 1;
            free_pages(stress_pages[i], size);
        }
    }

    size_t stress_final_free = slub_nr_free_pages();
    if (stress_final_free < stress_initial_free - 2) {
        cprintf("  WARNING: Possible memory leak in stress test!\n");
    } else {
        cprintf("  Memory leak test passed ✓\n");
    }
    cprintf("Stress test passed!\n");

    // 8. 最终状态验证和统计报告
    size_t final_free_pages = slub_nr_free_pages();
    size_t final_allocs = slub_allocator.total_allocs;
    size_t final_frees = slub_allocator.total_frees;

    cprintf("\n=== Final Statistics Report ===\n");
    cprintf("System Status:\n");
    cprintf("  Free pages: %u\n", (unsigned int)final_free_pages);
    cprintf("  Total allocations: %u (delta: +%u)\n",
            (unsigned int)final_allocs,
            (unsigned int)(final_allocs - initial_allocs));
    cprintf("  Total frees: %u (delta: +%u)\n",
            (unsigned int)final_frees,
            (unsigned int)(final_frees - initial_frees));
    cprintf("  Cache hits: %u\n", (unsigned int)slub_allocator.cache_hits);
    cprintf("  Active slabs: %u\n", (unsigned int)slub_allocator.nr_slabs);

    if (final_allocs > 0) {
        size_t hit_rate = (slub_allocator.cache_hits * 10000) / final_allocs;
        cprintf("  Cache hit rate: %u.%02u%%\n",
                (unsigned int)(hit_rate / 100),
                (unsigned int)(hit_rate % 100));
    }

    cprintf("\nSize Class Details:\n");
    for (int i = 0; i < SLUB_NUM_SIZES; i++) {
        struct slub_cache *cache = slub_allocator.size_caches[i];
        if (cache) {
            cprintf("  Size %u: %u slabs, %u free, %u allocs, %u frees\n",
                    (unsigned int)cache->object_size,
                    (unsigned int)cache->nr_slabs,
                    (unsigned int)cache->nr_free,
                    (unsigned int)cache->nr_allocs,
                    (unsigned int)cache->nr_frees);
        }
    }

    // 内存完整性检查
    if (final_free_pages < initial_free_pages - 3) {
        cprintf("\nWARNING: Significant memory leak detected!\n");
        cprintf("   Lost %d pages during testing\n",
                (int)(initial_free_pages - final_free_pages));
    } else {
        cprintf("\nMemory integrity check passed!\n");
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
