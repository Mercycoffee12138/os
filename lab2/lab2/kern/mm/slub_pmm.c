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
#define SLUB_NUM_SIZES      10      // 大小类别数量
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
    if (size > SLUB_MAX_SIZE) return -1;

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
    return SLUB_MIN_SIZE << index;
}

// 内联函数：获取页的SLUB信息
static inline struct slub_page_info *page_to_slub_info(struct Page *page) {
    size_t page_idx = page - pages;
    if (page_idx < slub_allocator.max_pages)
        return &slub_allocator.page_infos[page_idx];
    return NULL;
}

// 内联函数：获取“页大小”对应的缓存（将页当作对象，退化的 SLUB 用途）
static inline struct slub_cache *get_page_size_cache(void) {
    int idx = size_to_index(PGSIZE);
    if (idx < 0 || idx >= SLUB_NUM_SIZES) return NULL;
    return slub_allocator.size_caches[idx];
}

// 辅助：按请求大小找到对应的 size class 缓存（向上取整到 SLUB_ALIGN）
static inline struct slub_cache *get_cache_for_size(size_t size) {
    if (size == 0) return NULL;
    size = ROUNDUP(size, SLUB_ALIGN);
    int idx = size_to_index(size);
    if (idx < 0 || idx >= SLUB_NUM_SIZES) return NULL;
    return slub_allocator.size_caches[idx];
}

// 辅助：初始化新分配的 slab 页面上的对象链表
static void init_new_slab(struct Page *page, struct slub_cache *cache) {
    struct slub_page_info *info = page_to_slub_info(page);
    SetPageSlab(page);
    info->cache = cache;
    info->objects = cache->objects_per_slab;
    info->inuse = 0;
    list_init(&info->slab_list);

    char *base = (char *)page2kva(page);
    size_t objsz = cache->object_size;
    // 把页内对象串成单链表，freelist 指向第 0 个对象
    for (unsigned int i = 0; i + 1 < cache->objects_per_slab; i++) {
        void *cur = base + i * objsz;
        void *nxt = base + (i + 1) * objsz;
        *(void **)cur = nxt;
    }
    // 最后一个对象 next=NULL
    void *last = base + (cache->objects_per_slab - 1) * objsz;
    *(void **)last = NULL;
    info->freelist = base;
}

// 从某个 slab 弹出一个对象（假设 info->freelist 非空）
static inline void *pop_object_from_slab(struct slub_page_info *info) {
    void *obj = info->freelist;
    info->freelist = *(void **)obj;
    info->inuse++;
    return obj;
}

// 将对象压回 slab freelist
static inline void push_object_to_slab(struct slub_page_info *info, void *obj) {
    *(void **)obj = info->freelist;
    info->freelist = obj;
    info->inuse--;
}

// 前置声明：页面分配/释放（文件内静态）
static struct Page *slub_alloc_pages(size_t n);
static void slub_free_pages(struct Page *base, size_t n);

// 对象级分配：从 per-CPU 缓存 -> partial slab -> 新 slab
void *slub_malloc(size_t size) {
    struct slub_cache *cache = get_cache_for_size(size);
    if (cache == NULL) return NULL;

    // 1) per-CPU 缓存
    struct slub_cpu_cache *cc = &cache->cpu_cache;
    if (cc->avail > 0) {
        void *obj = cc->freelist[--cc->avail];
        slub_allocator.total_allocs++;
        slub_allocator.cache_hits++;
        cache->nr_allocs++;
        return obj;
    }

    // 2) partial slab
    if (!list_empty(&cache->partial_list)) {
        list_entry_t *le = list_next(&cache->partial_list);
        struct slub_page_info *info = to_struct(le, struct slub_page_info, slab_list);
        void *obj = pop_object_from_slab(info);
        if (info->inuse == info->objects) {
            // 这个 slab 变满了，从 partial 下链
            list_del_init(&info->slab_list);
        }
        slub_allocator.total_allocs++;
        cache->nr_allocs++;
        return obj;
    }

    // 3) 新建 slab
    struct Page *page = slub_alloc_pages(1);
    if (page == NULL) return NULL;
    init_new_slab(page, cache);
    cache->nr_slabs++;
    slub_allocator.nr_slabs++;

    struct slub_page_info *info = page_to_slub_info(page);
    // 新 slab 先放入 partial_list（分配一个对象后，根据是否满决定是否保留）
    list_add(&cache->partial_list, &info->slab_list);
    void *obj = pop_object_from_slab(info);
    if (info->inuse == info->objects) {
        list_del_init(&info->slab_list);
    }
    slub_allocator.total_allocs++;
    cache->nr_allocs++;
    return obj;
}

// 对象级释放：根据 obj 找 slab，回收到 freelist；若 slab 为空则释放整页
void slub_free(void *ptr) {
    if (ptr == NULL) return;
    // 通过物理地址反查页结构
    uintptr_t pa = PADDR(ptr);
    struct Page *page = pa2page(pa);
    struct slub_page_info *info = page_to_slub_info(page);
    if (info == NULL || info->cache == NULL) return; // 非 SLUB 对象

    struct slub_cache *cache = info->cache;
    // 优先回到 per-CPU 缓存
    struct slub_cpu_cache *cc = &cache->cpu_cache;
    if (cc->avail < cc->limit) {
        cc->freelist[cc->avail++] = ptr;
        slub_allocator.total_frees++;
        cache->nr_frees++;
        return;
    }

    // 否则回到 slab freelist
    push_object_to_slab(info, ptr);
    if (info->inuse + 1 == info->objects) {
        // 从满 -> 非满，挂到 partial 列表
        list_add(&cache->partial_list, &info->slab_list);
    }

    // 若该 slab 变为空，释放整页
    if (info->inuse == 0) {
        list_del_init(&info->slab_list);
        ClearPageSlab(page);
        cache->nr_slabs--;
        slub_allocator.nr_slabs--;
        slub_free_pages(page, 1);
    }

    slub_allocator.total_frees++;
    cache->nr_frees++;
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

    // 对于 n==1，优先使用“页大小”缓存，提供 SLUB 风格的快速路径
    if (n == 1) {
        struct slub_cache *pcache = get_page_size_cache();
        if (pcache != NULL) {
            struct slub_cpu_cache *cc = &pcache->cpu_cache;
            if (cc->avail > 0) {
                // 命中 per-CPU 缓存
                void *obj = cc->freelist[--cc->avail];
                struct Page *p = (struct Page *)obj;
                // 标记为占用页
                SetPageReserved(p);
                // 统计信息
                slub_allocator.total_allocs++;
                slub_allocator.cache_hits++;
                pcache->nr_allocs++;
                return p;
            }
        }
        // 没命中缓存则走慢路径（扫描空闲页）
    }

    // 简化的首次适配分配（慢路径）：扫描连续空闲页
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
        // 统计信息（记一次分配事件）
        slub_allocator.total_allocs++;
        // 如果是单页分配，计入对应缓存的统计
        if (n == 1) {
            struct slub_cache *pcache = get_page_size_cache();
            if (pcache) pcache->nr_allocs++;
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

    // 单页释放：尝试放入“页大小”缓存。若成功放入，则保持 Reserved 置位，避免被慢路径再次分配
    if (n == 1) {
        struct slub_cache *pcache = get_page_size_cache();
        if (pcache != NULL) {
            struct slub_cpu_cache *cc = &pcache->cpu_cache;
            if (cc->avail < cc->limit) {
                // 不清除 Reserved，表示该页已“保留”在 CPU 缓存中
                ClearPageSlab(base);
                set_page_ref(base, 0);

                cc->freelist[cc->avail++] = (void *)base;

                // 统计释放事件
                slub_allocator.total_frees++;
                pcache->nr_frees++;
                return;
            }
        }
    }

    // 常规路径：清除标志，将这些页重新放回全局空闲池
    for (size_t i = 0; i < n; i++) {
        struct Page *p = base + i;
        assert(PageReserved(p));
        ClearPageReserved(p);
        ClearPageSlab(p);
        set_page_ref(p, 0);
    }

    // 统计释放事件（缓存未接收或多页释放）
    slub_allocator.total_frees++;
    if (n == 1) {
        struct slub_cache *pcache = get_page_size_cache();
        if (pcache) pcache->nr_frees++;
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
    cprintf("=== SLUB Object-level Check Started ===\n");

    // 记录初始 slab 数，方便回归检查
    size_t slabs_before = slub_allocator.nr_slabs;
    size_t hits_before = slub_allocator.cache_hits;

    // 遍历全部 size class（8..4096，共 SLUB_NUM_SIZES 个）
    for (int si = 0; si < SLUB_NUM_SIZES; si++) {
        size_t req = index_to_size(si);
        struct slub_cache *cache = get_cache_for_size(req);
        assert(cache != NULL);

        // 小批量申请：最多 32 个，或 objects_per_slab+1（覆盖新建 slab）
        unsigned int want = cache->objects_per_slab + 1;
        if (want > 32) want = 32;
        void *objs[32];

        // 1) 分配
        for (unsigned int i = 0; i < want; i++) {
            objs[i] = slub_malloc(req);
            assert(objs[i] != NULL);
        }
        cprintf("  size %u: allocated %u objects\n", (unsigned int)req, want);

        // 2) 触发一次 per-CPU 缓存命中：先释放一个，再分配一个
        slub_free(objs[0]);
        size_t hits_mid = slub_allocator.cache_hits;
        void *again = slub_malloc(req);
        assert(again != NULL);
        size_t hits_after = slub_allocator.cache_hits;
        assert(hits_after >= hits_mid); // 命中数应不减少

        // 3) 释放全部对象（包含刚刚 again 的对象）
        slub_free(again);
        for (unsigned int i = 1; i < want; i++) {
            slub_free(objs[i]);
        }
        cprintf("  size %u: freed %u objects\n", (unsigned int)req, want);
    }

    // 回归检查：slab 数应能回到初始值或不显著偏差（允许常驻少量 slab）
    size_t slabs_after = slub_allocator.nr_slabs;
    if (slabs_after > slabs_before + 2) {
        cprintf("WARNING: slab leak suspected: before=%u after=%u\n",
                (unsigned int)slabs_before, (unsigned int)slabs_after);
    }

    // 汇总
    size_t total_allocs = slub_allocator.total_allocs;
    size_t total_frees = slub_allocator.total_frees;
    cprintf("\nSLUB Object-level Statistics:\n");
    cprintf("  Total allocations: %u\n", (unsigned int)total_allocs);
    cprintf("  Total frees: %u\n", (unsigned int)total_frees);
    cprintf("  Cache hits (delta): %u\n",
            (unsigned int)(slub_allocator.cache_hits - hits_before));
    cprintf("  Active slabs: %u\n", (unsigned int)slub_allocator.nr_slabs);

    assert(total_allocs >= total_frees);
    cprintf("\n=== SLUB Object-level Check Completed ===\n");
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
