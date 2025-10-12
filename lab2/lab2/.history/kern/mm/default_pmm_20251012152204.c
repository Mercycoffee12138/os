#include <pmm.h>
#include <list.h>
#include <string.h>
#include <default_pmm.h>

/* 在首次适应算法（First Fit Algorithm）中，分配器维护一个空闲块列表（称为 free list），
   当收到内存请求时，会沿着链表扫描，寻找第一个足够大的块来满足请求。
   如果选中的块明显大于所需大小，通常会将其拆分，剩余部分作为另一个空闲块加入列表。
   参考阎维民《数据结构——C语言版》第8.2节第196~198页。
*/
// LAB2 EXERCISE 1: 你的代码
// 你需要重写以下函数：default_init, default_init_memmap, default_alloc_pages, default_free_pages.
/*
 * FFMA（首次适应分配算法）细节
 * (1) 准备：为了实现首次适应分配（FFMA），我们需要用链表管理空闲内存块。
 *              结构体 free_area_t 用于管理空闲内存块。首先你要熟悉 list.h 里的 struct list。
 *              struct list 是一个简单的双向链表实现。
 *              你需要了解如何使用：list_init, list_add（list_add_after）, list_add_before, list_del, list_next, list_prev。
 *              另一个技巧是将一般的 list 结构体转换为特定结构体（如 struct page）：
 *              你可以找到一些宏：le2page（在 memlayout.h），（后续实验还有 le2vma（在 vmm.h），le2proc（在 proc.h）等）。
 * (2) default_init：你可以复用演示的 default_init 函数来初始化 free_list 并将 nr_free 设为 0。
 *              free_list 用于记录空闲内存块。nr_free 是空闲内存块的总数。
 * (3) default_init_memmap：调用流程：kern_init --> pmm_init --> page_init --> init_memmap --> pmm_manager->init_memmap
 *              这个函数用于初始化一个空闲块（参数：addr_base, page_number）。
 *              首先你需要初始化这个空闲块中的每个 page（见 memlayout.h），包括：
 *                  p->flags 应设置 PG_property 位（表示该页有效。在 pmm_init（pmm.c）中，p->flags 已设置 PG_reserved 位）
 *                  如果该页是空闲且不是空闲块的第一个页，p->property 应设为 0。
 *                  如果该页是空闲且是空闲块的第一个页，p->property 应设为整个块的总页数。
 *                  p->ref 应设为 0，因为现在 p 是空闲的，没有引用。
 *                  可以用 p->page_link 将该页链接到 free_list（如：list_add_before(&free_list, &(p->page_link));）
 *              最后，应该累加空闲块的数量：nr_free += n
 * (4) default_alloc_pages：在空闲链表中查找第一个空闲块（块大小 >= n），并调整空闲块大小，返回分配块的地址。
 *              (4.1) 你可以这样遍历空闲链表：
 *                       list_entry_t le = &free_list;
 *                       while((le = list_next(le)) != &free_list) {
 *                       ....
 *                 (4.1.1) 在 while 循环中，获取 struct page 并检查 p->property（记录空闲块的页数）是否 >= n？
 *                       struct Page *p = le2page(le, page_link);
 *                       if(p->property >= n){ ...
 *                 (4.1.2) 如果找到了 p，说明找到了一个空闲块（块大小 >= n），前 n 页可以分配。
 *                     需要设置该页的一些标志位：PG_reserved = 1, PG_property = 0
 *                     从 free_list 中解除这些页的链接
 *                     (4.1.2.1) 如果 (p->property > n)，需要重新计算剩余空闲块的数量，
 *                           （如：le2page(le, page_link)->property = p->property - n;）
 *                 (4.1.3) 重新计算所有剩余空闲块的 nr_free
 *                 (4.1.4) 返回 p
 *               (4.2) 如果找不到空闲块（块大小 >= n），则返回 NULL
 * (5) default_free_pages：将页重新链接到空闲链表，可能需要合并小空闲块为大空闲块。
 *               (5.1) 根据回收块的基地址，遍历空闲链表，找到正确位置（从低地址到高地址），插入这些页。（可用 list_next, le2page, list_add_before）
 *               (5.2) 重置页的字段，如 p->ref, p->flags（PageProperty）
 *               (5.3) 尝试合并低地址或高地址的块。注意：应正确修改某些页的 p->property。
 */
static free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
}

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    //这里只是初始化了管理信息，而非页面本身
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p));//每个page都被标记为pagereserved
        p->flags = p->property = 0;//
        set_page_ref(p, 0);//引用计数设置为0，表示未被使用
    }

    base->property = n;
    SetPageProperty(base);
    nr_free += n;
    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }
}

static struct Page *
default_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
        list_entry_t* prev = list_prev(&(page->page_link));
        list_del(&(page->page_link));
        if (page->property > n) {
            struct Page *p = page + n;
            p->property = page->property - n;
            SetPageProperty(p);
            list_add(prev, &(p->page_link));
        }
        nr_free -= n;
        ClearPageProperty(page);
    }
    return page;
}

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;

    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }

    list_entry_t* le = list_prev(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
        if (p + p->property == base) {
            p->property += base->property;
            ClearPageProperty(base);
            list_del(&(base->page_link));
            base = p;
        }
    }

    le = list_next(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
        if (base + base->property == p) {
            base->property += p->property;
            ClearPageProperty(p);
            list_del(&(p->page_link));
        }
    }
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}

static void
basic_check(void) {
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    assert(alloc_page() == NULL);

    free_page(p0);
    free_page(p1);
    free_page(p2);
    assert(nr_free == 3);

    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(alloc_page() == NULL);

    free_page(p0);
    assert(!list_empty(&free_list));

    struct Page *p;
    assert((p = alloc_page()) == p0);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    free_list = free_list_store;
    nr_free = nr_free_store;

    free_page(p);
    free_page(p1);
    free_page(p2);
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
    assert(p0 != NULL);
    assert(!PageProperty(p0));

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
    assert(alloc_pages(4) == NULL);
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
    assert((p1 = alloc_pages(3)) != NULL);
    assert(alloc_page() == NULL);
    assert(p0 + 2 == p1);

    p2 = p0 + 1;
    free_page(p0);
    free_pages(p1, 3);
    assert(PageProperty(p0) && p0->property == 1);
    assert(PageProperty(p1) && p1->property == 3);

    assert((p0 = alloc_page()) == p2 - 1);
    free_page(p0);
    assert((p0 = alloc_pages(2)) == p2 + 1);

    free_pages(p0, 2);
    free_page(p2);

    assert((p0 = alloc_pages(5)) != NULL);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
    assert(total == 0);
}

const struct pmm_manager default_pmm_manager = {
    .name = "default_pmm_manager",
    .init = default_init,
    .init_memmap = default_init_memmap,
    .alloc_pages = default_alloc_pages,
    .free_pages = default_free_pages,
    .nr_free_pages = default_nr_free_pages,
    .check = default_check,
};

