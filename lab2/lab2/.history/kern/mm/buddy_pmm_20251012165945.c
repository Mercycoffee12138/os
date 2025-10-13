#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_pmm.h>
#include <stdio.h>

#define MAX_ORDER 10 // 最大阶数，2^10=1024页（可根据实际内存调整）

typedef struct {
    list_entry_t free_list[MAX_ORDER + 1]; // 每阶一个链表
    unsigned int nr_free[MAX_ORDER + 1];   // 每阶空闲块数
} buddy_area_t;

static buddy_area_t buddy_area;

static void buddy_init(void) {
    for (int i = 0; i <= MAX_ORDER; i++) {
        list_init(&buddy_area.free_list[i]);
        buddy_area.nr_free[i] = 0;
    }
}

static void buddy_init_memmap(struct Page *base, size_t n) {
    // 初始化为最大阶的块
    size_t order = MAX_ORDER;
    while (n > 0) {
        while ((1 << order) > n) order--;
        struct Page *p = base;
        p->property = 1 << order;
        SetPageProperty(p);
        set_page_ref(p, 0);
        list_add(&buddy_area.free_list[order], &(p->page_link));
        buddy_area.nr_free[order]++;
        base += (1 << order);
        n -= (1 << order);
    }
}

static struct Page *buddy_alloc_pages(size_t n) {
    // 找到最小满足的阶
    size_t order = 0;
    while ((1 << order) < n && order <= MAX_ORDER) order++;
    if (order > MAX_ORDER) return NULL;

    size_t found_order = order;
    while (found_order <= MAX_ORDER && list_empty(&buddy_area.free_list[found_order])) found_order++;
    if (found_order > MAX_ORDER) return NULL;

    // 从 found_order 阶分裂到 order 阶
    list_entry_t *le = list_next(&buddy_area.free_list[found_order]);
    struct Page *p = le2page(le, page_link);
    list_del(le);
    buddy_area.nr_free[found_order]--;

    while (found_order > order) {
        found_order--;
        struct Page *buddy = p + (1 << found_order);
        buddy->property = 1 << found_order;
        SetPageProperty(buddy);
        set_page_ref(buddy, 0);
        list_add(&buddy_area.free_list[found_order], &(buddy->page_link));
        buddy_area.nr_free[found_order]++;
    }

    p->property = n;
    ClearPageProperty(p); // 已分配
    return p;
}

static void buddy_free_pages(struct Page *base, size_t n) {
    size_t order = 0;
    while ((1 << order) < n && order <= MAX_ORDER) order++;
    assert((1 << order) == n);

    struct Page *p = base;
    p->property = n;
    SetPageProperty(p);
    set_page_ref(p, 0);

    // 合并伙伴块
    while (order < MAX_ORDER) {
        uintptr_t addr = page2pa(p);
        uintptr_t buddy_addr = addr ^ (n * PGSIZE);
        struct Page *buddy = pa2page(buddy_addr);

        if (!PageProperty(buddy) || buddy->property != n) break;

        // 找到并移除伙伴块
        list_entry_t *le = &(buddy->page_link);
        list_del(le);
        buddy_area.nr_free[order]--;

        // 合并
        if (buddy < p) p = buddy;
        n <<= 1;
        p->property = n;
        order++;
    }
    list_add(&buddy_area.free_list[order], &(p->page_link));
    buddy_area.nr_free[order]++;
}

static size_t buddy_nr_free_pages(void) {
    size_t total = 0;
    for (int i = 0; i <= MAX_ORDER; i++) {
        total += buddy_area.nr_free[i] * (1 << i);
    }
    return total;
}

// 测试用例（可扩展）
static void buddy_check(void) {
    // 分配、释放、合并测试
    struct Page *p1 = buddy_alloc_pages(1);
    struct Page *p2 = buddy_alloc_pages(2);
    struct Page *p4 = buddy_alloc_pages(4);
    assert(p1 && p2 && p4);
    buddy_free_pages(p1, 1);
    buddy_free_pages(p2, 2);
    buddy_free_pages(p4, 4);
    assert(buddy_nr_free_pages() > 0);
}

const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};