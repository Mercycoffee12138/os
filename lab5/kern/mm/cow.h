#ifndef __KERN_MM_COW_H__
#define __KERN_MM_COW_H__

#include <defs.h>

// PTE 中的 COW 标记位定义
#define PTE_COW (1 << 10)

// 页面 COW 状态定义
#define PAGE_STATE_INDEPENDENT  0
#define PAGE_STATE_COW_SHARED   1
#define PAGE_STATE_COW_PENDING  2
#define PAGE_STATE_COPIED       3

// COW 核心函数声明
int mark_cow_page(struct mm_struct *mm, uintptr_t va, struct Page *page);
int is_cow_fault(struct trapframe *tf, uintptr_t va);
int handle_cow_fault(uintptr_t va);
int dup_mmap_cow(struct mm_struct *to_mm, struct mm_struct *from_mm);
void cleanup_cow_pages(struct mm_struct *mm);

#endif /* __KERN_MM_COW_H__ */
