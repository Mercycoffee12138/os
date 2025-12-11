# uCore Copy-On-Write (COW) 机制设计报告

## 1. 概述

Copy-On-Write (COW) 是一种内存优化技术，广泛应用于现代操作系统中。当父进程通过 `fork()` 创建子进程时，传统方法会复制父进程的整个地址空间，这不仅浪费时间还浪费内存。COW 机制通过延迟复制来优化这一过程：父子进程最初共享相同的物理页面，只有当某一方尝试写入时才真正复制该页面。

## 2. 设计目标

1. **内存效率**：避免不必要的内存复制，节省物理内存
2. **时间效率**：加速 `fork()` 系统调用
3. **正确性**：确保父子进程的内存隔离
4. **兼容性**：对用户程序透明，无需修改现有程序

## 3. 实现架构

### 3.1 核心组件

```
┌─────────────────────────────────────────────────────────────────┐
│                        COW 实现架构                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌─────────────┐      ┌─────────────┐      ┌─────────────┐      │
│  │   mmu.h     │      │   pmm.c     │      │   trap.c    │      │
│  │ PTE_COW标志 │      │ copy_range  │      │ page fault  │      │
│  │   定义      │      │ do_cow_fault│      │   处理      │      │
│  └─────────────┘      └─────────────┘      └─────────────┘      │
│         │                    │                    │              │
│         └────────────────────┼────────────────────┘              │
│                              │                                    │
│                    ┌─────────▼─────────┐                         │
│                    │      vmm.c        │                         │
│                    │    dup_mmap       │                         │
│                    │  (启用COW共享)    │                         │
│                    └───────────────────┘                         │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 文件修改清单

| 文件               | 修改内容                                         |
| ------------------ | ------------------------------------------------ |
| `kern/mm/mmu.h`    | 添加 `PTE_COW` 标志位定义                        |
| `kern/mm/pmm.h`    | 添加 `do_cow_fault` 函数声明                     |
| `kern/mm/pmm.c`    | 修改 `copy_range` 函数，添加 `do_cow_fault` 函数 |
| `kern/mm/vmm.c`    | 修改 `dup_mmap` 函数启用 COW                     |
| `kern/trap/trap.c` | 添加 Store Page Fault 的 COW 处理                |
| `user/cowtest.c`   | 新增 COW 测试程序                                |

## 4. 页面状态转换 (有限状态自动机)

### 4.1 状态定义

页面在 COW 机制中可能处于以下状态：

| 状态                      | PTE 标志                             | 描述                       |
| ------------------------- | ------------------------------------ | -------------------------- |
| **私有可写** (Private-RW) | `PTE_V \| PTE_R \| PTE_W \| PTE_U`   | 进程独占的可写页面         |
| **共享只读** (Shared-RO)  | `PTE_V \| PTE_R \| PTE_U \| PTE_COW` | COW 共享页面，等待写时复制 |
| **无效** (Invalid)        | `0`                                  | 页面未映射                 |

### 4.2 状态转换图

```
                              ┌──────────────────────────────────────┐
                              │                                      │
                              ▼                                      │
    ┌─────────────┐      fork()      ┌─────────────────┐            │
    │             │ ─────────────────▶│                 │            │
    │ Private-RW  │                   │   Shared-RO    │            │
    │ (私有可写)   │◀──── COW复制 ────│   (共享只读)    │            │
    │             │   (写入触发)      │   ref_count++  │            │
    └─────────────┘                   └────────┬───────┘            │
          ▲                                    │                     │
          │                                    │ 写入触发             │
          │                                    │ Page Fault           │
          │                                    ▼                     │
          │                           ┌─────────────────┐            │
          │                           │  do_cow_fault   │            │
          │                           │                 │            │
          │                           │ if ref==1:     │            │
          │                           │   直接改权限    │────────────┘
          │                           │ else:          │
          │                           │   分配新页      │
          │                           │   复制内容      │
          │                           │   ref_count--  │
          │                           └────────┬───────┘
          │                                    │
          └────────────────────────────────────┘
```

### 4.3 状态转换详细说明

#### 转换 1: Private-RW → Shared-RO (fork 触发)

```
触发条件: 父进程调用 fork() 创建子进程
操作:
  1. 在 copy_range() 中，对于每个可写页面:
     - 移除父进程 PTE 的 PTE_W 权限
     - 添加 PTE_COW 标志
     - 子进程 PTE 设置相同的只读权限和 COW 标志
     - 物理页引用计数 +1
  2. 刷新 TLB

状态变化:
  父进程页面: Private-RW → Shared-RO
  子进程页面: 无 → Shared-RO (指向同一物理页)
  物理页 ref_count: 1 → 2
```

#### 转换 2: Shared-RO → Private-RW (写入触发)

```
触发条件: 进程写入 COW 共享页面
异常类型: CAUSE_STORE_PAGE_FAULT

处理流程:
  1. 检测到写入只读页面，触发 Store Page Fault
  2. 检查 PTE 是否有 PTE_COW 标志
  3. 如果 ref_count == 1:
     - 直接移除 PTE_COW，添加 PTE_W
     - 刷新 TLB
  4. 如果 ref_count > 1:
     - 分配新物理页
     - 复制原页面内容
     - 更新 PTE 指向新页面，设置可写权限
     - 原页面 ref_count--
     - 刷新 TLB

状态变化:
  当前进程页面: Shared-RO → Private-RW
  其他共享进程: Shared-RO (不变)
  原物理页 ref_count: N → N-1
  新物理页 ref_count: 0 → 1
```

### 4.4 完整状态自动机

```
          ┌─────────────────────────────────────────────────────────────┐
          │                     页面状态自动机                           │
          └─────────────────────────────────────────────────────────────┘

                                   ┌────────────┐
                                   │  Invalid   │
                                   │   (初始)   │
                                   └──────┬─────┘
                                          │
                                          │ 首次访问/分配
                                          ▼
                    ┌─────────────────────────────────────────────────┐
                    │                                                   │
       fork()       │               ┌─────────────────┐                │
      (share=1)     │               │   Private-RW    │                │
    ┌───────────────│───────────────│   ref_count=1   │                │
    │               │               │   PTE_W 设置    │                │
    │               │               └────────┬────────┘                │
    │               │                        │                         │
    │               │                        │ fork()                  │
    │               │                        ▼                         │
    │               │               ┌─────────────────┐                │
    │               │               │   Shared-RO     │◄───────────────┘
    │               └──────────────▶│   ref_count>1   │   子进程也指向
    │                               │   PTE_COW 设置  │   同一物理页
    │                               └────────┬────────┘
    │                                        │
    │                                        │ 写入 (任一共享者)
    │                                        │ Page Fault
    │                                        ▼
    │                               ┌─────────────────┐
    │                               │  COW Handler    │
    │                               │                 │
    │                               │ ref==1? ────────┼──┐
    │                               │                 │  │ 是: 直接改权限
    │                               │ ref>1? ─────────┼──┤
    │                               │                 │  │ 否: 复制页面
    │                               └─────────────────┘  │
    │                                        │           │
    │                                        │           │
    │                                        ▼           │
    │                               ┌─────────────────┐  │
    └──────────────────────────────▶│   Private-RW    │◄─┘
                                    │   ref_count=1   │
                                    │   PTE_W 设置    │
                                    └─────────────────┘

    ═══════════════════════════════════════════════════════════════════
    图例:
    ─────▶  状态转换
    ref_count  物理页引用计数
    PTE_W      页表项可写标志
    PTE_COW    页表项 Copy-On-Write 标志
    ═══════════════════════════════════════════════════════════════════
```

## 5. 关键代码实现

### 5.1 PTE_COW 标志定义 (mmu.h)

```c
// COW (Copy-On-Write) flag - using one of the software-reserved bits
#define PTE_COW 0x100  // Copy-On-Write page (bit 8, in PTE_SOFT range)
```

### 5.2 copy_range 函数修改 (pmm.c)

```c
int copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share)
{
    // ... 省略检查代码 ...

    if (share) {
        // COW mechanism: share the physical page instead of copying
        // Remove write permission and add COW flag
        uint32_t cow_perm = (perm & ~PTE_W) | PTE_COW;

        // Update parent's PTE to be read-only with COW flag
        *ptep = pte_create(page2ppn(page), cow_perm);
        tlb_invalidate(from, start);

        // Set child's PTE to same read-only page with COW flag
        *nptep = pte_create(page2ppn(page), cow_perm);

        // Increase reference count
        page_ref_inc(page);
    } else {
        // Original behavior: copy page content
        // ...
    }
}
```

### 5.3 do_cow_fault 函数实现 (pmm.c)

```c
int do_cow_fault(struct mm_struct *mm, uintptr_t addr, pte_t *ptep)
{
    struct Page *old_page = pte2page(*ptep);
    uint32_t perm = (*ptep & PTE_USER);
    perm = (perm & ~PTE_COW) | PTE_W;  // Remove COW, add write

    if (page_ref(old_page) == 1) {
        // Only one reference, just update permissions
        *ptep = pte_create(page2ppn(old_page), perm);
        tlb_invalidate(mm->pgdir, addr);
        return 0;
    }

    // Multiple references, need to copy
    struct Page *new_page = alloc_page();
    if (new_page == NULL) return -E_NO_MEM;

    memcpy(page2kva(new_page), page2kva(old_page), PGSIZE);

    page_ref_dec(old_page);
    if (page_ref(old_page) == 0) free_page(old_page);

    set_page_ref(new_page, 1);
    *ptep = pte_create(page2ppn(new_page), perm);
    tlb_invalidate(mm->pgdir, addr);

    return 0;
}
```

### 5.4 Page Fault 处理 (trap.c)

```c
case CAUSE_STORE_PAGE_FAULT:
    if (current != NULL && current->mm != NULL) {
        uintptr_t addr = tf->tval;
        struct mm_struct *mm = current->mm;
        struct vma_struct *vma = find_vma(mm, addr);

        if (vma != NULL && (vma->vm_flags & VM_WRITE)) {
            pte_t *ptep = get_pte(mm->pgdir, addr, 0);
            if (ptep != NULL && (*ptep & PTE_V) && (*ptep & PTE_COW)) {
                int ret = do_cow_fault(mm, addr, ptep);
                if (ret == 0) break;  // COW handled successfully
            }
        }
    }
    // Handle as regular page fault if COW doesn't apply
    break;
```

## 6. Dirty COW 漏洞分析

### 6.1 漏洞背景

Dirty COW (CVE-2016-5195) 是 Linux 内核中一个严重的提权漏洞，存在于 2007 年至 2016 年期间。该漏洞利用了 COW 机制与 `/proc/self/mem` 写入操作之间的竞态条件。

### 6.2 漏洞原理

```
正常 COW 流程:
  1. 进程 A fork 出进程 B，共享只读页面
  2. 进程 B 尝试写入 → 触发 Page Fault
  3. COW 处理: 复制页面，更新 PTE，写入新页面

Dirty COW 攻击流程:
  1. 攻击者打开只读文件 (如 /etc/passwd)
  2. 将文件 mmap 到内存
  3. 创建两个竞争线程:
     - 线程 1: 通过 /proc/self/mem 写入映射地址
     - 线程 2: 使用 madvise(MADV_DONTNEED) 丢弃页面
  4. 竞态条件: 在 COW 复制完成后、写入新页面前，
     页面被丢弃并重新映射到原始只读文件
  5. 结果: 写入操作实际写入了只读文件!
```

### 6.3 竞态条件时序图

```
        线程1 (写入)                   线程2 (madvise)           内核 COW 处理
            │                              │                          │
            │   write(/proc/self/mem)      │                          │
            ├──────────────────────────────┼──────────────────────────▶│
            │                              │                          │
            │                              │           ┌──────────────┤
            │                              │           │ 1. 分配新页   │
            │                              │           │ 2. 复制内容   │
            │                              │           └──────────────┤
            │                              │                          │
            │                              │  madvise(DONTNEED)       │
            │                              ├──────────────────────────▶│
            │                              │           ┌──────────────┤
            │                              │           │ 丢弃页面      │
            │                              │           │ PTE 指向原页  │
            │                              │           └──────────────┤
            │                              │                          │
            │                              │           ┌──────────────┤
            │                              │           │ 3. 写入数据   │
            │                              │           │ (写入原只读页!)│
            │                              │           └──────────────┤
            │                              │                          │
            ▼                              ▼                          ▼
```

### 6.4 在 uCore 中模拟 Dirty COW

#### 6.4.1 潜在漏洞场景

在我们的 uCore 实现中，如果添加以下功能可能引入类似漏洞：

1. **`/proc/self/mem` 接口**: 允许进程写入自己的内存
2. **`madvise` 系统调用**: 允许进程建议内核丢弃页面

#### 6.4.2 模拟漏洞代码

```c
// 假设 uCore 添加了 madvise 和 /proc/self/mem
// 这是潜在的漏洞触发场景

// 漏洞版本的 COW 处理 (有问题)
int buggy_cow_fault(struct mm_struct *mm, uintptr_t addr, pte_t *ptep)
{
    struct Page *old_page = pte2page(*ptep);
    struct Page *new_page = alloc_page();

    // 步骤1: 复制页面内容
    memcpy(page2kva(new_page), page2kva(old_page), PGSIZE);

    // *** 竞态窗口开始 ***
    // 如果此时另一个线程调用 madvise(MADV_DONTNEED)
    // PTE 可能被重置指向原始只读页面

    // 步骤2: 更新 PTE (可能已被另一线程修改!)
    *ptep = pte_create(page2ppn(new_page), perm);

    // *** 竞态窗口结束 ***

    // 如果 PTE 已被修改，new_page 永远不会被使用
    // 后续写入将写入原始只读页面!

    return 0;
}
```

### 6.5 解决方案

#### 6.5.1 原子性保护

```c
// 修复版本: 使用锁保护整个 COW 过程
int secure_cow_fault(struct mm_struct *mm, uintptr_t addr, pte_t *ptep)
{
    bool intr_flag;
    local_intr_save(intr_flag);  // 关中断
    {
        // 重新检查 PTE 状态 (double-check)
        if (!(*ptep & PTE_COW)) {
            local_intr_restore(intr_flag);
            return 0;  // 已被其他线程处理
        }

        struct Page *old_page = pte2page(*ptep);
        struct Page *new_page = alloc_page();

        // 原子地完成: 复制 + 更新 PTE
        memcpy(page2kva(new_page), page2kva(old_page), PGSIZE);

        page_ref_dec(old_page);
        set_page_ref(new_page, 1);

        *ptep = pte_create(page2ppn(new_page), perm);
        tlb_invalidate(mm->pgdir, addr);
    }
    local_intr_restore(intr_flag);

    return 0;
}
```

#### 6.5.2 我们实现中的安全措施

当前 uCore 实现具有以下安全特性：

1. **无 /proc/self/mem**: 没有允许进程写入任意内存地址的接口
2. **无 madvise**: 没有允许用户控制页面丢弃的系统调用
3. **单处理器**: 没有多核并发问题
4. **简化的内存模型**: 没有复杂的文件映射机制

```c
// 当前实现的安全版本
int do_cow_fault(struct mm_struct *mm, uintptr_t addr, pte_t *ptep)
{
    struct Page *old_page = pte2page(*ptep);
    uint32_t perm = (*ptep & PTE_USER);
    perm = (perm & ~PTE_COW) | PTE_W;

    // 单进程环境下，引用计数检查是安全的
    if (page_ref(old_page) == 1) {
        *ptep = pte_create(page2ppn(old_page), perm);
        tlb_invalidate(mm->pgdir, addr);
        return 0;
    }

    struct Page *new_page = alloc_page();
    if (new_page == NULL) return -E_NO_MEM;

    // 复制和更新在无中断情况下是原子的
    memcpy(page2kva(new_page), page2kva(old_page), PGSIZE);

    page_ref_dec(old_page);
    if (page_ref(old_page) == 0) free_page(old_page);

    set_page_ref(new_page, 1);
    *ptep = pte_create(page2ppn(new_page), perm);
    tlb_invalidate(mm->pgdir, addr);

    return 0;
}
```

### 6.6 如果要在 uCore 中引入 Dirty COW 风险

如果未来 uCore 添加以下功能，需要特别注意：

1. **多线程支持**: 需要使用细粒度锁保护 PTE 修改
2. **madvise 系统调用**: 需要与 COW 处理互斥
3. **/proc 文件系统**: 需要限制内存写入的权限检查

```c
// 多线程环境下的安全实现建议
int mt_safe_cow_fault(struct mm_struct *mm, uintptr_t addr, pte_t *ptep)
{
    lock_mm(mm);  // 获取 mm 锁

    // Double-check pattern
    if (!(*ptep & PTE_V) || !(*ptep & PTE_COW)) {
        unlock_mm(mm);
        return -E_INVAL;
    }

    struct Page *old_page = pte2page(*ptep);

    // 尝试获取页面锁 (防止 madvise 干扰)
    lock_page(old_page);

    if (page_ref(old_page) == 1) {
        uint32_t perm = ((*ptep & PTE_USER) & ~PTE_COW) | PTE_W;
        *ptep = pte_create(page2ppn(old_page), perm);
        tlb_invalidate(mm->pgdir, addr);
        unlock_page(old_page);
        unlock_mm(mm);
        return 0;
    }

    struct Page *new_page = alloc_page();
    if (new_page == NULL) {
        unlock_page(old_page);
        unlock_mm(mm);
        return -E_NO_MEM;
    }

    memcpy(page2kva(new_page), page2kva(old_page), PGSIZE);

    page_ref_dec(old_page);
    set_page_ref(new_page, 1);

    uint32_t perm = ((*ptep & PTE_USER) & ~PTE_COW) | PTE_W;
    *ptep = pte_create(page2ppn(new_page), perm);
    tlb_invalidate(mm->pgdir, addr);

    unlock_page(old_page);
    unlock_mm(mm);

    if (page_ref(old_page) == 0) free_page(old_page);

    return 0;
}
```

## 7. 测试用例说明

### 7.1 测试程序 (cowtest.c)

| 测试名称             | 测试内容      | 预期结果               |
| -------------------- | ------------- | ---------------------- |
| test_basic_cow       | 基本 COW 功能 | 子进程修改不影响父进程 |
| test_array_cow       | 大数组 COW    | 数组修改正确隔离       |
| test_multi_fork_cow  | 多次 fork     | 每个子进程独立         |
| test_nested_fork_cow | 嵌套 fork     | 多层 fork 正确隔离     |
| test_read_no_cow     | 只读访问      | 不触发不必要的 COW     |

### 7.2 运行测试

```bash
make
make run
# 在 uCore shell 中运行:
$ cowtest
```

## 8. 性能分析

### 8.1 COW 优势

| 场景        | 传统 fork      | COW fork      |
| ----------- | -------------- | ------------- |
| fork() 时间 | O(n) 页面复制  | O(1) PTE 修改 |
| 内存使用    | 立即翻倍       | 按需分配      |
| exec() 后   | 浪费已复制页面 | 几乎无浪费    |

### 8.2 COW 开销

1. **Page Fault 处理**: 每次写入共享页面需要异常处理
2. **TLB 刷新**: 权限变更需要刷新 TLB
3. **引用计数维护**: 需要额外的内存操作

## 9. 总结

本设计报告详细描述了 uCore 操作系统中 Copy-On-Write 机制的实现，包括：

1. **完整的状态转换模型**: 清晰定义了页面在 COW 生命周期中的状态变化
2. **核心代码实现**: 提供了可运行的代码修改
3. **Dirty COW 漏洞分析**: 深入分析了著名漏洞的原理和防范措施
4. **测试用例**: 提供了全面的功能验证程序

通过 COW 机制，uCore 能够更高效地处理 `fork()` 系统调用，同时保证进程间的内存隔离。
