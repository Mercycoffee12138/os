#include <defs.h>
#include <vmm.h>
#include <pmm.h>
#include <error.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <riscv.h>
#include <sync.h>
#include <proc.h>

// PTE 中的 COW 标记位定义
#define PTE_COW (1 << 10)

// 页面 COW 状态定义
#define PAGE_STATE_INDEPENDENT  0
#define PAGE_STATE_COW_SHARED   1
#define PAGE_STATE_COW_PENDING  2
#define PAGE_STATE_COPIED       3

/**
 * mark_cow_page - 标记页面为 COW 共享状态
 * @mm: 内存管理结构
 * @va: 虚拟地址
 * @page: 物理页面指针
 * 
 * 返回值：成功返回 0，失败返回负数错误代码
 */
int mark_cow_page(struct mm_struct *mm, uintptr_t va, struct Page *page)
{
    pte_t *pte;
    
    if ((pte = get_pte(mm->pgdir, va, 0)) == NULL)
        return -E_INVAL;
    
    // 增加页面引用计数
    page_ref_inc(page);
    
    // 设置 PTE：清除写权限，添加 COW 标记
    pte_t perm = (*pte & ~PTE_W) | PTE_COW;
    *pte = (*pte & 0xFFFFF000) | perm;
    
    return 0;
}

/**
 * is_cow_fault - 检测是否为 COW 故障
 * @tf: trapframe 结构
 * @va: 故障虚拟地址
 * 
 * 返回值：是 COW 故障返回 1，否则返回 0
 */
int is_cow_fault(struct trapframe *tf, uintptr_t va)
{
    pte_t *pte;
    
    // 检查异常原因：存储页故障
    if (tf->cause != CAUSE_STORE_PAGE_FAULT)
        return 0;
    
    // 获取页表项
    pte = get_pte(current->mm->pgdir, va, 0);
    if (pte == NULL)
        return 0;
    
    // 页表项必须有效
    if (!(*pte & PTE_V))
        return 0;
    
    // 检查是否标记为 COW
    if (!(*pte & PTE_COW))
        return 0;
    
    return 1;
}

/**
 * handle_cow_fault - 处理 COW 故障（核心逻辑）
 * @va: 故障虚拟地址
 * 
 * 流程：
 * 1. 在关中断状态下获取原页面信息
 * 2. 分配新物理页面
 * 3. 拷贝数据
 * 4. 在关中断状态下更新核心数据结构
 * 5. 刷新 TLB
 * 
 * 返回值：成功返回 0，失败返回负数错误代码
 */
int handle_cow_fault(uintptr_t va)
{
    struct Page *old_page, *new_page;
    pte_t *pte;
    void *src_kva, *dst_kva;
    bool intr_flag;
    
    // 第一步：在关中断状态下获取原页面信息（Double-check pattern）
    local_intr_save(intr_flag);
    {
        pte = get_pte(current->mm->pgdir, va, 0);
        if (pte == NULL || !(*pte & PTE_V) || !(*pte & PTE_COW)) {
            local_intr_restore(intr_flag);
            return -E_INVAL;
        }
        
        old_page = pte2page(*pte);
        if (old_page == NULL) {
            local_intr_restore(intr_flag);
            return -E_INVAL;
        }
    }
    local_intr_restore(intr_flag);
    
    // 第二步：分配新物理页面
    if ((new_page = alloc_page()) == NULL)
        return -E_NO_MEM;
    
    // 第三步：拷贝数据（防 Dirty COW 的关键）
    src_kva = page2kva(old_page);
    dst_kva = page2kva(new_page);
    memcpy(dst_kva, src_kva, PGSIZE);
    
    // 第四步：在关中断状态下更新核心数据结构
    local_intr_save(intr_flag);
    {
        // 减少原页面的引用计数
        page_ref_dec(old_page);
        
        // 如果没有其他进程使用该页面，释放它
        if (page_ref(old_page) == 0) {
            free_page(old_page);
        }
        
        // 建立新映射：指向新页面，标记为可读写
        pte_t perm = PTE_U | PTE_V | PTE_R | PTE_W | PTE_X;
        page_insert(current->mm->pgdir, new_page, va, perm);
        
        // 标记新页面为独占页面
        set_page_ref(new_page, 1);
    }
    local_intr_restore(intr_flag);
    
    // 第五步：刷新 TLB
    tlb_invalidate(current->mm->pgdir, va);
    
    return 0;
}

/**
 * dup_mmap_cow - 以 COW 方式复制页表范围
 * @to_mm: 目标内存管理结构（子进程）
 * @from_mm: 源内存管理结构（父进程）
 * 
 * 返回值：成功返回 0，失败返回负数错误代码
 */
int dup_mmap_cow(struct mm_struct *to_mm, struct mm_struct *from_mm)
{
    struct vma_struct *vma;
    list_entry_t *list = &from_mm->mmap_list, *le = list;
    uintptr_t va;
    pte_t *from_pte, *to_pte;
    struct Page *page;
    
    while ((le = list_next(le)) != list) {
        vma = le2vma(le, list_link);
        
        // 仅对用户空间、可写的 VMA 进行 COW
        if (!(vma->vm_flags & VM_WRITE))
            continue;
        
        // 遍历 VMA 内的所有虚拟页面
        for (va = vma->vm_start; va < vma->vm_end; va += PGSIZE) {
            // 获取源进程的页表项
            from_pte = get_pte(from_mm->pgdir, va, 0);
            if (from_pte == NULL || !(*from_pte & PTE_V))
                continue;
            
            // 获取目标进程的页表项（如果不存在则创建）
            if ((to_pte = get_pte(to_mm->pgdir, va, 1)) == NULL)
                return -E_NO_MEM;
            
            // 获取原页面指针
            page = pte2page(*from_pte);
            
            // 在目标进程的页表中建立映射
            // 清除写权限，添加 COW 标记
            pte_t perm = (*from_pte & ~PTE_W) | PTE_COW;
            *to_pte = (*from_pte & 0xFFFFF000) | perm;
            
            // 增加页面引用计数
            page_ref_inc(page);
        }
    }
    
    return 0;
}

/**
 * cleanup_cow_pages - 进程退出时清理 COW 页面
 * @mm: 内存管理结构
 * 
 * 清理进程使用的 COW 页面，正确处理引用计数
 */
void cleanup_cow_pages(struct mm_struct *mm)
{
    if (mm == NULL)
        return;
    
    struct vma_struct *vma;
    list_entry_t *list = &mm->mmap_list, *le = list;
    uintptr_t va;
    pte_t *pte;
    struct Page *page;
    
    // 遍历所有虚拟地址空间
    while ((le = list_next(le)) != list) {
        vma = le2vma(le, list_link);
        
        for (va = vma->vm_start; va < vma->vm_end; va += PGSIZE) {
            pte = get_pte(mm->pgdir, va, 0);
            if (pte == NULL || !(*pte & PTE_V))
                continue;
            
            page = pte2page(*pte);
            
            // 如果是 COW 页面，减少引用计数
            if (*pte & PTE_COW) {
                page_ref_dec(page);
                if (page_ref(page) == 0) {
                    free_page(page);
                }
            } else {
                // 独占页面直接释放
                free_page(page);
            }
        }
    }
}
