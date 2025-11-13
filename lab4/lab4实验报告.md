# Lab4：进程管理

## 练习1：分配并初始化一个进程控制块

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

2. struct trapframe *tf

   > 它是一次 trap/中断/异常现场的完整寄存器快照，包含所有14个通用寄存器、status、epc 等。
   >
   > 作用：新线程创建时，copy_thread 将模板 trapframe 拷到“线程内核栈顶附近”，并令 proc->tf 指向它。首次调度通过 forkret(current->tf) 设置 sp 并跳到 __trapret，按统一的 trap 返回路径恢复 tf，最终 sret 到 epc=kernel_thread_entry，再进入线程入口函数（如 init_main）。

- context 用于“线程与线程之间”的调度切换（轻量寄存器集）。

- trapframe 用于“陷入与返回”的完整现场恢复（通用返回路径）。

  一个新线程要首次运行时，它的运行路径是：switch_to → forkret → forkrets(tf) → __trapret（恢复 tf）→ sret 到 kernel_thread_entry → 线程函数。