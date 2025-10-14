#ifndef __KERN_MM_SLUB_PMM_H__
#define __KERN_MM_SLUB_PMM_H__

#include <pmm.h>
#include <list.h>
#include <defs.h>
#include <memlayout.h>

// SLUB分配器常量定义
#define SLUB_MIN_SIZE       8       // 最小对象大小（字节）
#define SLUB_MAX_SIZE       4096    // 最大对象大小（字节）
#define SLUB_ALIGN          8       // 默认对齐大小
#define SLUB_SHIFT_HIGH     12      // log2(SLUB_MAX_SIZE)
#define SLUB_SHIFT_LOW      3       // log2(SLUB_MIN_SIZE)
#define SLUB_NUM_SIZES      (SLUB_SHIFT_HIGH - SLUB_SHIFT_LOW + 1)

// CPU缓存相关常量
#define SLUB_CPU_CACHE_SIZE 16      // 每CPU缓存最大对象数

// SLUB特定的页标志位
#define PG_slab             2       // 页属于SLUB slab

// Slab页标志操作
#define SetPageSlab(page)       ((page)->flags |= (1UL << PG_slab))
#define ClearPageSlab(page)     ((page)->flags &= ~(1UL << PG_slab))
#define PageSlab(page)          (((page)->flags >> PG_slab) & 1)

/* SLUB每CPU缓存结构 */
struct slub_cpu_cache {
    void **freelist;            // 空闲对象指针数组
    struct Page *page;          // 当前活动的slab页
    unsigned int avail;         // 当前可用对象数
    unsigned int limit;         // 缓存容量限制
};

/* SLUB缓存对象结构 */
struct slub_cache {
    const char *name;           // 缓存名称
    size_t object_size;         // 对象大小
    size_t align;              // 对齐要求
    unsigned int objects_per_slab; // 每个slab的对象数量

    // 每CPU缓存（简化为单CPU）
    struct slub_cpu_cache cpu_cache;

    // 部分空闲的slab链表
    list_entry_t partial_list;

    // 统计信息
    size_t nr_slabs;           // slab总数
    size_t nr_objects;         // 对象总数
    size_t nr_free;           // 空闲对象数
    size_t nr_allocs;         // 分配次数
    size_t nr_frees;          // 释放次数
};

/* SLUB页扩展信息（通过Page结构的property字段存储索引） */
struct slub_page_info {
    void *freelist;           // 页内空闲对象链表
    unsigned int inuse;       // 已使用对象数
    unsigned int objects;     // 总对象数
    struct slub_cache *cache; // 所属缓存指针
    list_entry_t slab_list;   // 用于链接到partial_list
};

/* SLUB全局分配器 */
struct slub_allocator {
    // 按大小分类的缓存数组
    struct slub_cache *size_caches[SLUB_NUM_SIZES];

    // 全局统计
    size_t total_allocs;      // 总分配次数
    size_t total_frees;       // 总释放次数
    size_t cache_hits;        // CPU缓存命中次数
    size_t nr_slabs;          // 总slab数量

    // 页信息数组（索引对应页号）
    struct slub_page_info *page_infos;
    size_t max_pages;         // 最大页数
};

// 内联函数：获取页的SLUB信息
static inline struct slub_page_info *page_to_slub_info(struct Page *page) {
    extern struct slub_allocator slub_allocator;
    size_t page_idx = page - pages;
    if (page_idx < slub_allocator.max_pages) {
        return &slub_allocator.page_infos[page_idx];
    }
    return NULL;
}

// 内联函数：根据大小计算size class索引
static inline int size_to_index(size_t size) {
    if (size <= SLUB_MIN_SIZE) return 0;
    if (size > SLUB_MAX_SIZE) return -1;

    // 计算需要的2的幂次
    int shift = 0;
    size_t temp = size - 1;
    while (temp > 0) {
        temp >>= 1;
        shift++;
    }

    return shift - SLUB_SHIFT_LOW;
}

// 内联函数：根据索引计算对象大小
static inline size_t index_to_size(int index) {
    if (index < 0 || index >= SLUB_NUM_SIZES) return 0;
    return SLUB_MIN_SIZE << index;
}

// PMM管理器接口函数声明
void slub_init(void);
void slub_init_memmap(struct Page *base, size_t n);
struct Page *slub_alloc_pages(size_t n);
void slub_free_pages(struct Page *base, size_t n);
size_t slub_nr_free_pages(void);
void slub_check(void);

// SLUB内部函数声明
void *slub_alloc(size_t size);
void slub_free(void *ptr, size_t size);
struct slub_cache *slub_cache_create(const char *name, size_t size, size_t align);
void slub_cache_destroy(struct slub_cache *cache);

// 调试和统计函数
void slub_print_stats(void);
void slub_print_cache_info(struct slub_cache *cache);

// 导出的PMM管理器
extern const struct pmm_manager slub_pmm_manager;

#endif /* !__KERN_MM_SLUB_PMM_H__ */