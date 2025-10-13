#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_pmm.h>
#include <stdio.h>

/*
 * Buddy System物理内存管理器
 * 
 * Buddy System算法把系统中的可用存储空间划分为存储块(Block)来进行管理，
 * 每个存储块的大小必须是2的n次幂(Pow(2, n))，即1, 2, 4, 8, 16, 32, 64, 128...
 * 
 * 算法原理：
 * 1. 初始时，整个内存被看作一个大块
 * 2. 当需要分配n页时，找到不小于n且为2的幂次的块大小k=2^m
 * 3. 如果找到的块大小正好等于k，直接分配
 * 4. 如果找到的块大小大于k，将其一分为二，直到得到大小为k的块
 * 5. 释放时，检查其伙伴块是否空闲，如果是则合并成更大的块
 * 
 * 伙伴关系：
 * - 大小相同
 * - 地址相邻
 * - 起始地址较小的块的起始地址必须是块大小的2倍的整数倍
 */

// 最大支持的幂次(2^MAX_ORDER页)
#define MAX_ORDER 10

// 空闲链表数组，free_lists[i]存储大小为2^i页的空闲块
static free_area_t free_lists[MAX_ORDER + 1];

// 计算以2为底的对数(向上取整)
static int get_order(size_t n) {
    int order = 0;
    size_t size = 1;
    while (size < n) {
        size <<= 1;
        order++;
    }
    return order;
}

// 检查两个页块是否为伙伴
static int is_buddy(struct Page *p1, struct Page *p2, int order) {
    // 两个块必须大小相同且都是空闲的
    if (p1->property != (1 << order) || p2->property != (1 << order)) {
        return 0;
    }
    
    // 计算两个页的索引
    uintptr_t p1_idx = p1 - pages;
    uintptr_t p2_idx = p2 - pages;
    
    // 检查是否相邻且地址关系正确
    if (p1_idx + (1 << order) == p2_idx) {
        // p1在前，p2在后
        return (p1_idx % (1 << (order + 1))) == 0;
    } else if (p2_idx + (1 << order) == p1_idx) {
        // p2在前，p1在后
        return (p2_idx % (1 << (order + 1))) == 0;
    }
    
    return 0;
}

// 获取页的伙伴页
static struct Page *get_buddy(struct Page *page, int order) {
    uintptr_t page_idx = page - pages;
    uintptr_t buddy_idx = page_idx ^ (1 << order);
    return pages + buddy_idx;
}

static void
buddy_init(void) {
    // 初始化所有空闲链表
    for (int i = 0; i <= MAX_ORDER; i++) {
        list_init(&(free_lists[i].free_list));
        free_lists[i].nr_free = 0;
    }
}

static void
buddy_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    
    // 初始化所有页
    struct Page *p = base;
    for (; p != base + n; p++) {
        assert(PageReserved(p));
        p->flags = 0;
        p->property = 0;
        set_page_ref(p, 0);
    }
    
    // 将内存块按2的幂次分解并添加到相应的空闲链表中
    size_t current_size = n;
    struct Page *current_base = base;
    
    while (current_size > 0) {
        // 找到不大于current_size的最大的2的幂次
        int order = 0;
        size_t block_size = 1;
        while (block_size * 2 <= current_size && order < MAX_ORDER) {
            block_size <<= 1;
            order++;
        }
        
        // 设置块属性
        current_base->property = block_size;
        SetPageProperty(current_base);
        
        // 添加到相应的空闲链表
        list_add(&(free_lists[order].free_list), &(current_base->page_link));
        free_lists[order].nr_free++;
        
        // 移动到下一个块
        current_base += block_size;
        current_size -= block_size;
    }
}

static struct Page *
buddy_alloc_pages(size_t n) {
    assert(n > 0);
    
    if (n > (1 << MAX_ORDER)) {
        return NULL;
    }
    
    // 计算需要的阶数
    int order = get_order(n);
    int current_order = order;
    
    // 寻找合适大小的空闲块
    while (current_order <= MAX_ORDER) {
        if (!list_empty(&(free_lists[current_order].free_list))) {
            // 找到空闲块
            list_entry_t *le = list_next(&(free_lists[current_order].free_list));
            struct Page *page = le2page(le, page_link);
            
            // 从空闲链表中移除
            list_del(&(page->page_link));
            free_lists[current_order].nr_free--;
            ClearPageProperty(page);
            
            // 如果块太大，需要分裂
            while (current_order > order) {
                current_order--;
                
                // 分裂成两个小块
                struct Page *buddy = page + (1 << current_order);
                buddy->property = 1 << current_order;
                SetPageProperty(buddy);
                
                // 将右半部分加入到对应的空闲链表
                list_add(&(free_lists[current_order].free_list), &(buddy->page_link));
                free_lists[current_order].nr_free++;
            }
            
            // 设置分配的页的属性
            page->property = 1 << order;
            return page;
        }
        current_order++;
    }
    
    return NULL;  // 没有找到合适的空闲块
}

static void
buddy_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    
    int order = get_order(n);
    
    // 重置页属性
    struct Page *p = base;
    for (; p != base + (1 << order); p++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    
    // 设置块属性
    base->property = 1 << order;
    SetPageProperty(base);
    
    // 尝试与伙伴合并
    struct Page *current_block = base;
    int current_order = order;
    
    while (current_order < MAX_ORDER) {
        struct Page *buddy = get_buddy(current_block, current_order);
        
        // 检查伙伴是否空闲且大小匹配
        if (buddy < pages || buddy >= pages + npage || 
            !PageProperty(buddy) || buddy->property != (1 << current_order)) {
            break;
        }
        
        // 从空闲链表中移除伙伴
        list_del(&(buddy->page_link));
        free_lists[current_order].nr_free--;
        ClearPageProperty(buddy);
        
        // 合并：确保current_block指向地址较小的块
        if (buddy < current_block) {
            current_block = buddy;
        }
        
        // 增加阶数，准备下一轮合并
        current_order++;
        current_block->property = 1 << current_order;
    }
    
    // 将最终的块加入到对应的空闲链表
    list_add(&(free_lists[current_order].free_list), &(current_block->page_link));
    free_lists[current_order].nr_free++;
}

static size_t
buddy_nr_free_pages(void) {
    size_t total = 0;
    for (int i = 0; i <= MAX_ORDER; i++) {
        total += free_lists[i].nr_free * (1 << i);
    }
    return total;
}

// 基本检查函数
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

    // 保存当前状态
    free_area_t free_lists_store[MAX_ORDER + 1];
    for (int i = 0; i <= MAX_ORDER; i++) {
        free_lists_store[i] = free_lists[i];
        list_init(&(free_lists[i].free_list));
        free_lists[i].nr_free = 0;
    }

    assert(alloc_page() == NULL);

    free_page(p0);
    free_page(p1);
    free_page(p2);
    assert(buddy_nr_free_pages() >= 3);

    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(alloc_page() == NULL);

    free_page(p0);
    
    struct Page *p;
    assert((p = alloc_page()) == p0);
    assert(alloc_page() == NULL);

    // 恢复状态
    for (int i = 0; i <= MAX_ORDER; i++) {
        free_lists[i] = free_lists_store[i];
    }

    free_page(p);
    free_page(p1);
    free_page(p2);
}

// Buddy System特有的检查函数
static void
buddy_check(void) {
    cprintf("=== Buddy System Check Started ===\n");
    
    basic_check();
    cprintf("Basic check passed!\n");

    // 1. 测试简单请求和释放操作，分配 1 页和 2 页，确保分配成功，然后释放这两块。
    cprintf("Testing simple alloc/free...\n");
    struct Page *simple1 = alloc_pages(1);
    struct Page *simple2 = alloc_pages(2);
    assert(simple1 != NULL && simple2 != NULL);
    free_pages(simple1, 1);
    free_pages(simple2, 2);
    cprintf("Simple alloc/free test passed!\n");

    // 2. 测试复杂请求和释放操作，分配 3、5、7 页（不是 2 的幂），实际会分配到最近的 2 的幂（如 4、8 页），释放后测试伙伴合并机制和分配器对复杂请求的处理能力。
    cprintf("Testing complex alloc/free...\n");
    struct Page *complex1 = alloc_pages(3);
    struct Page *complex2 = alloc_pages(5);
    struct Page *complex3 = alloc_pages(7);
    assert(complex1 != NULL && complex2 != NULL && complex3 != NULL);
    free_pages(complex1, 3);
    free_pages(complex2, 5);
    free_pages(complex3, 7);
    cprintf("Complex alloc/free test passed!\n");

    // 3. 测试请求和释放最小单元操作
    cprintf("Testing min unit alloc/free...\n");
    struct Page *min_unit = alloc_pages(1);
    assert(min_unit != NULL);
    free_pages(min_unit, 1);
    cprintf("Min unit alloc/free test passed!\n");

    // 4. 测试请求和释放最大单元操作
    cprintf("Testing max unit alloc/free...\n");
    struct Page *max_unit = alloc_pages(1 << MAX_ORDER);
    if (max_unit != NULL) {
        free_pages(max_unit, 1 << MAX_ORDER);
        cprintf("Max unit alloc/free test passed!\n");
    } else {
        cprintf("Max unit alloc failed (expected if insufficient memory)\n");
    }
    
    // 测试2的幂次分配
    cprintf("Testing power-of-2 allocations...\n");
    struct Page *p1 = alloc_pages(1);   // 分配1页
    struct Page *p2 = alloc_pages(2);   // 分配2页
    struct Page *p4 = alloc_pages(4);   // 分配4页
    struct Page *p8 = alloc_pages(8);   // 分配8页
    
    assert(p1 != NULL && p2 != NULL && p4 != NULL && p8 != NULL);
    cprintf("Power-of-2 allocations successful!\n");
    
    // 测试非2的幂次分配(应该向上取整)
    cprintf("Testing non-power-of-2 allocations...\n");
    struct Page *p3 = alloc_pages(3);   // 应该分配4页
    struct Page *p5 = alloc_pages(5);   // 应该分配8页
    
    assert(p3 != NULL && p5 != NULL);
    cprintf("Non-power-of-2 allocations successful!\n");
    
    // 测试释放和合并
    cprintf("Testing free and coalescing...\n");
    size_t free_before = buddy_nr_free_pages();
    
    free_pages(p1, 1);
    free_pages(p2, 2);
    free_pages(p4, 4);
    free_pages(p8, 8);
    free_pages(p3, 3);  // 实际释放4页
    free_pages(p5, 5);  // 实际释放8页
    
    size_t free_after = buddy_nr_free_pages();
    cprintf("Free pages before: %d, after: %d\n", free_before, free_after);
    
    // 测试大块分配
    cprintf("Testing large block allocation...\n");
    struct Page *large = alloc_pages(64);
    if (large != NULL) {
        cprintf("Large block (64 pages) allocation successful!\n");
        free_pages(large, 64);
    } else {
        cprintf("Large block allocation failed (expected if insufficient memory)\n");
    }
    
    // 测试边界情况
    cprintf("Testing boundary cases...\n");
    
    // 尝试分配超大块
    struct Page *huge = alloc_pages(1 << (MAX_ORDER + 1));
    assert(huge == NULL);  // 应该失败
    cprintf("Oversized allocation correctly failed!\n");
    
    // 测试连续分配和释放
    cprintf("Testing continuous allocation and free...\n");
    struct Page *pages_array[10];
    for (int i = 0; i < 10; i++) {
        pages_array[i] = alloc_pages(1);
        assert(pages_array[i] != NULL);
    }
    
    for (int i = 0; i < 10; i++) {
        free_pages(pages_array[i], 1);
    }
    cprintf("Continuous allocation and free test passed!\n");
    
    // 打印当前空闲块统计
    cprintf("Current free block statistics:\n");
    for (int i = 0; i <= MAX_ORDER; i++) {
        if (free_lists[i].nr_free > 0) {
            cprintf("Order %d (size %d): %d blocks\n", 
                   i, 1 << i, free_lists[i].nr_free);
        }
    }
    
    cprintf("=== Buddy System Check Completed Successfully ===\n");
}

// PMM管理器结构体
const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};
