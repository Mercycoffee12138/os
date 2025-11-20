# Lab4：进程管理

## 练习 1：分配并初始化一个进程控制块

### 目标与思路

在内核创建线程之前，先通过 alloc_proc 分配并“最小初始化”一个进程控制块（PCB，struct proc_struct），不做任何资源分配（例如内核栈、地址空间复制、trapframe 构造）。这样可以保证 PCB 处于可预测的未就绪状态，便于后续步骤（setup_kstack/copy_mm/copy_thread/插入队列/唤醒）顺利进行。

本实验以 proc_init 中的自检为准，初始化后的 idleproc 必须满足检查条件，说明 alloc_proc 的默认值正确。

### 初始化内容

alloc_proc 在 kmalloc 成功后，仅设置以下“基本字段”值：

```c
state = PROC_UNINIT;                          // 初始态，尚未就绪
pid = -1;                                     // 未分配真实 pid，后续由 get_pid 赋值
runs = 0;                                     // 运行计数清零
kstack = 0;                                   // 尚未分配内核栈，后续 setup_kstack
need_resched = 0;                             // 默认不请求调度
parent = NULL;                                // 父子关系在 fork 时建立
mm = NULL;                                    // 地址空间复制/共享在 copy_mm 处理
memset(&proc->context, 0, sizeof(struct context)); // context 清零
tf = NULL;                                    // 等待分配内核栈后由 copy_thread 建立
pgdir = boot_pgdir_pa;                        // 本工程使用物理地址，与 proc_init 的检查一致
flags = 0;                                    // 初始无标志
memset(proc->name, 0, sizeof(proc->name));    // name 清零，后续 set_proc_name 设置
```

> 链表指针（list_link/hash_link）由插入全局队列或哈希表时处理，alloc_proc 不需要改动。
>
> 资源分配与入口设置（内核栈、trapframe、context.ra/sp）由 setup_kstack 与 copy_thread 完成。

### 问题：

1. struct context context

   > 用于保存调度切换需要的少量寄存器（RISC-V 的 callee-saved 寄存器，含 ra/sp/s0~s11）。
   >
   > 作用：在 switch_to(&from->context, &to->context) 时保存/恢复这组寄存器，实现线程之间的上下文切换。新线程首次运行前，copy_thread 会设置 context.ra=forkret、context.sp=trapframe，使切换后先进入 forkret。

2. struct trapframe \*tf

   > 它是一次 trap/中断/异常现场的完整寄存器快照，包含所有 14 个通用寄存器、status、epc 等。
   >
   > 作用：新线程创建时，copy_thread 将模板 trapframe 拷到“线程内核栈顶附近”，并令 proc->tf 指向它。首次调度通过 forkret(current->tf) 设置 sp 并跳到 \_\_trapret，按统一的 trap 返回路径恢复 tf，最终 sret 到 epc=kernel_thread_entry，再进入线程入口函数（如 init_main）。

- context 用于"线程与线程之间"的调度切换（轻量寄存器集）。

- trapframe 用于"陷入与返回"的完整现场恢复（通用返回路径）。

  一个新线程要首次运行时，它的运行路径是：switch_to → forkret → forkrets(tf) → \_\_trapret（恢复 tf）→ sret 到 kernel_thread_entry → 线程函数。

## 练习2：为新创建的内核线程分配资源

### 目标与思路

本练习目标是完善 `do_fork`，实现内核线程创建时的资源分配和状态复制。具体包括：分配进程控制块、内核栈、复制上下文和 trapframe、维护进程父子关系、分配唯一进程号、插入进程队列并唤醒新线程。这样可以保证新线程能被调度运行，并正确维护进程树结构。

本练习我们的目标是：实现`do_fork`函数，为新建的内核线程分配必要的资源，包括进程控制块、内核栈、内存管理信息等，并完成进程的初始化和调度准备。

设计思路和实现流程如下：

1. 调用`alloc_proc`分配进程控制块
2. 调用`setup_kstack`分配内核栈空间
3. 调用`copy_mm`复制或共享内存管理信息
4. 调用`copy_thread`设置陷阱帧和执行上下文
5. 将新进程加入进程管理数据结构
6. 唤醒新进程使其进入就绪状态
7. 返回新进程的PID

### 代码实现

```c
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf)
{
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    // 检查进程数是否已达上限
    if (nr_process >= MAX_PROCESS)
    {
        goto fork_out;
    }
    ret = -E_NO_MEM;
    // 1. 分配并初始化进程控制块
    if ((proc = alloc_proc()) == NULL)
    {
        goto fork_out;
    }

    // 2. 设置父进程指针
    proc->parent = current;

    // 3. 维护父子链表关系
    proc->cptr = current->cptr;
    if (proc->cptr != NULL) {
        proc->cptr->optr = proc;
    }
    current->cptr = proc;
    proc->optr = NULL;
    proc->yptr = NULL;

    // 4. 分配内核栈
    if ((ret = setup_kstack(proc)) != 0)
    {
        goto bad_fork_cleanup_proc;
    }

    // 5. 复制或共享内存管理信息（本实验为内核线程，通常不处理 mm）
    if ((ret = copy_mm(clone_flags, proc)) != 0)
    {
        goto bad_fork_cleanup_kstack;
    }

    // 6. 复制trapframe和上下文
    copy_thread(proc, stack, tf);

    // 7. 分配唯一进程号
    proc->pid = get_pid();

    // 8. 插入哈希表和进程链表
    hash_proc(proc);
    list_add(&proc_list, &(proc->list_link));

    // 9. 增加进程计数
    nr_process++;

    // 10. 唤醒新进程
    wakeup_proc(proc);

    // 11. 返回新进程号
    ret = proc->pid;
fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
```



### 关键点说明

- **进程关系维护**：通过设置`cptr`、`optr`、`yptr`指针维护进程的父子兄弟关系，这是进程树管理的基础。

- **进程状态转换**：通过`wakeup_proc`将进程状态从PROC_UNINIT变为PROC_RUNNABLE，使其可被调度。

- **内核栈设置**：`setup_kstack`分配KSTACKPAGE大小的内核栈空间，为进程提供内核态执行环境。

- **执行上下文初始化**：`copy_thread`设置陷阱帧和上下文，其中：

  ​	1、设置`a0`寄存器为0，标识这是子进程

  ​	2、设置返回地址为`forkret`，确保首次调度时正确进入

- **错误处理机制**：使用goto语句实现资源的层级清理，保证在任何步骤失败时都能正确释放已分配的资源。
- **资源分配顺序**：严格按照"进程控制块→内核栈→内存管理→线程上下文"的顺序分配资源，确保前序资源分配失败时能正确回滚。

### 问题回答

**问：uCore是否做到给每个新fork的线程一个唯一的id？请说明你的分析和理由。**



**答：**`uCore`能够为每个新fork的线程分配唯一的PID

uCore通过 `get_pid` 函数为每个新fork的线程分配唯一的进程号（pid）。`get_pid` 会遍历所有已存在的进程，确保分配的 pid 不与当前系统中的任何进程重复。每次分配时，都会查重并跳过已被占用的 pid，最终保证每个新创建的进程（线程）都拥有唯一的 id。因此，uCore能够做到为每个新fork的线程分配唯一的 id，保证系统中所有进程（线程）的 pid 互不冲突。

1、`PID`分配机制：`uCore`通过`get_pid()`函数实现PID分配，该函数维护两个静态变量：

- `last_pid`：记录上次分配的PID
- `next_safe`：记录下一个安全的PID上限

2、唯一性保证算法：

- 首先尝试递增`last_pid`
- 如果`last_pid`达到或超过`next_safe`，则重新扫描进程列表
- 扫描过程中，如果发现PID冲突就递增`last_pid`，同时更新`next_safe`为大于`last_pid`的最小已用PID
- 通过这种"安全区间"机制确保分配的PID唯一

3、实现细节：

```c
static int get_pid(void) {
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    // ... 扫描进程列表，确保PID唯一性
    return last_pid;
}
```

4、**边界处理**：当PID达到MAX_PID时回绕到1重新开始，通过静态断言确保MAX_PID > MAX_PROCESS，避免PID耗尽。

5、**并发安全**：目前我们的实现未显式处理并发（之后的实验LAB应该会实现），但在单核环境下通过进程调度的串行性隐含保证了PID分配的安全性。

**总而言之言而总之**，ucore的PID分配机制能够有效地为每个新创建的线程分配唯一的进程标识符。

## 练习 3：编写 proc_run 函数

### 目标与思路

`proc_run` 用于将指定的进程切换到 CPU 上运行，实现进程的上下文切换。其核心流程包括：

1. 检查要切换的进程是否与当前正在运行的进程相同，如果相同则无需切换。
2. 禁用中断，保证切换过程的原子性（使用 `local_intr_save(x)` 和 `local_intr_restore(x)`）。
3. 切换当前进程指针 `current` 为目标进程。
4. 切换页表，使用 `lsatp(proc->pgdir)` 修改 SATP 寄存器，切换到新进程的地址空间。
5. 调用 `switch_to(&prev->context, &proc->context)` 实现上下文切换。
6. 允许中断，恢复系统响应能力。

### 代码实现

```c
void proc_run(struct proc_struct *proc)
{
    if (proc != current)
    {
        bool intr_flag;
        local_intr_save(intr_flag);                // 1. 关中断
        struct proc_struct *prev = current;
        current = proc;                            // 2. 切换当前进程
        lsatp(proc->pgdir);                        // 3. 切换页表
        switch_to(&(prev->context), &(proc->context)); // 4. 上下文切换
        local_intr_restore(intr_flag);             // 5. 开中断
    }
}
```

### 关键点说明

- `local_intr_save(x)` 和 `local_intr_restore(x)` 用于关/开中断，防止切换过程中被打断。
- `lsatp(pgdir)` 切换 SATP 寄存器，实现地址空间切换。
- `switch_to` 汇编实现，保存/恢复 RISC-V 的 callee-saved 寄存器，实现进程上下文切换。

### 问题回答

**在本实验的执行过程中，创建且运行了几个内核线程？**

答：**共创建并运行了 2 个内核线程**，分别是：

1. **idleproc（pid=0，内核空闲线程）**

   - 在 `proc_init()` 中创建
   - 通过 `alloc_proc()` 分配进程控制块
   - 设置 `pid=0`，状态为 `PROC_RUNNABLE`
   - 使用内核启动栈 `bootstack`
   - 在 `cpu_idle()` 中循环调用 `schedule()` 进行进程调度

2. **initproc（pid=1，初始化线程）**
   - 在 `proc_init()` 中通过 `kernel_thread(init_main, "Hello world!!", 0)` 创建
   - 运行 `init_main` 函数，打印初始化信息
   - 执行完毕后调用 `do_exit()` 退出

这两个线程都通过 `proc_run` 完成了切换到 CPU 上的运行。从运行输出可以验证：

```
alloc_proc() correct!                          // 练习1检查通过
this initproc, pid = 1, name = "init"         // initproc 运行了 init_main
To U: "Hello world!!".                         // 传递的参数被正确接收
To U: "en.., Bye, Bye. :)"                    // init_main 执行完毕
kernel panic at kern/process/proc.c:400:      // do_exit 还未实现
    process exit!!.
```
