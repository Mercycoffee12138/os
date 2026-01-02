# 练习1：理解调度器框架的实现

📋 本练习关注“调度器框架如何与具体调度算法解耦”，以及一次完整调度发生时，各模块的调用关系。

## 1) 调度类的初始化流程

内核启动到调度器初始化完成的关键链路如下（只列与调度相关的主干）：

- 在 `kern/init/init.c` 的 `kern_init()` 中，完成内存/中断/虚拟内存等初始化后，会调用 `sched_init()` 来初始化调度器框架。
- `sched_init()`（`kern/schedule/sched.c`）内部做了三件事：
  - 通过宏 `SCHED_ALGORITHM` 选择一个 `struct sched_class *sched_class`（如 `default_sched_class`/`stride_sched_class` 等）。
  - 初始化全局运行队列 `rq`（设置 `rq->max_time_slice` 并调用 `sched_class->init(rq)`）。
  - 输出当前调度类名字：`cprintf("sched class: %s\n", sched_class->name);`，用于 `grade.sh` 识别。

`default_sched_class` 与框架的关联方式是“函数指针绑定”：

- `default_sched_class` 在 `kern/schedule/default_sched.c` 里定义，提供 `.init/.enqueue/.dequeue/.pick_next/.proc_tick` 五个接口实现。
- 框架侧（`kern/schedule/sched.c`）只持有 `sched_class` 指针，并在调度发生时统一调用这些接口，因此核心调度代码不依赖任何具体算法细节。

## 2) 进程调度流程（含流程图）

一次完整的“抢占式调度”主要由 **时钟中断** 驱动，核心流程如下：

```
时钟中断 IRQ_S_TIMER 触发
  -> interrupt_handler() (kern/trap/trap.c)
     -> clock_set_next_event() / ticks 统计
     -> sched_class_proc_tick(current) (kern/schedule/sched.c)
        -> sched_class->proc_tick(rq, current)
           -> (RR) RR_proc_tick(): time_slice--，若为0则 current->need_resched=1

中断返回路径 (trap())：
  -> 若来自用户态 (in_kernel==false)
     -> if (current->need_resched) schedule()
        -> schedule() (kern/schedule/sched.c)
           -> current->need_resched = 0
           -> 若 current 仍为 PROC_RUNNABLE，则 sched_class_enqueue(current)
              -> sched_class->enqueue(rq, current)
           -> next = sched_class_pick_next()
              -> sched_class->pick_next(rq)
           -> sched_class_dequeue(next)
              -> sched_class->dequeue(rq, next)
           -> proc_run(next) 完成切换
```

`need_resched` 标志位的作用可以理解为“延迟调度请求”：

- 它不是立刻强行切换，而是由时钟中断或 `do_yield()` 等位置把 `need_resched` 置 1。
- 真正的调度发生在 **安全点**（这里是 trap 返回到用户态之前），由 `trap()` 统一检查并调用 `schedule()`。
- 这样设计能避免在不合适的上下文（例如内核关键路径/持锁区域）里直接做进程切换，提高正确性与可维护性。

## 3) 调度算法的切换机制（如何添加新算法）

如果要添加一个新的调度算法（例如 Stride），通常需要：

- 新增一个实现文件（例如 `kern/schedule/default_sched_stride.c`），定义一个新的 `struct sched_class xxx_sched_class`，并实现五个接口函数。
- 在头文件 `kern/schedule/default_sched.h` 中添加 `extern struct sched_class xxx_sched_class;` 方便框架侧引用。
- 在 `kern/schedule/sched.c` 的 `sched_init()` 里把 `sched_class` 指针指向新的调度类（本实验通过 `SCHED_ALGORITHM` 宏切换）。
- 确保新文件被编译进内核（根据工程构建方式，把 `.c` 文件加入构建列表即可）。

之所以切换变得容易，是因为：

- 框架 `schedule()` 只依赖 “统一的五个接口”，核心逻辑不需要为每个算法写分支。
- 新算法只需要在各自文件里维护自己的数据结构（链表/堆/多队列等），对其他模块影响很小。


# 练习2：实现 Round Robin（RR）调度算法

⚠️ 本练习的关键点在于：RR 是“抢占式”的时间片轮转，因此必须依赖时钟中断与 `need_resched` 机制才能工作。

## 1) 对比 Lab5 与 Lab6：同名函数为何必须改

我选择对比 `kern/schedule/sched.c` 中的 `schedule()`：

- **Lab5 的 `schedule()`**：直接在全局 `proc_list` 里循环查找下一个 `PROC_RUNNABLE` 进程（相当于“框架 + 策略”耦合在一起，策略偏 FIFO 扫描）。
- **Lab6 的 `schedule()`**：把“选择谁运行”的策略抽象成 `sched_class`，通过 `enqueue/pick_next/dequeue` 操作运行队列 `rq`，从而支持 RR/Stride/FIFO/Priority 等算法切换。

为什么要做这个改动：

- RR 需要维护“就绪队列”的队列语义（入队/出队/取队首）以及时间片耗尽后的重新入队；如果还用 Lab5 的线性扫描 `proc_list`，会导致算法实现分散、难以扩展，也不符合 Lab6 的调度框架设计。
- Lab6 的测试（含 `grade.sh`）也依赖 `sched_init()` 输出的 `sched class: <name>` 来判断调度器是否切换成功，框架化后更清晰。

此外，`wakeup_proc()` 在 Lab6 也做了关键调整：当进程从阻塞变为 RUNNABLE 时，会把它放入 `rq`（通过 `sched_class_enqueue`），否则新唤醒的进程不会进入调度器管理的就绪结构，可能“永远选不到”。

## 2) RR 各函数实现思路（含关键代码解释）

RR 的核心数据结构是 `run_queue.run_list`（循环双向链表，带哨兵头结点），实现目标是“先进先出 + 时间片轮转”。

- `RR_init(rq)`
  - 思路：把 `rq->run_list` 初始化为空链表，`rq->proc_num=0`。
  - 边界：空队列时 `pick_next()` 必须返回 NULL。

- `RR_enqueue(rq, proc)`
  - 思路：把 `proc->run_link` 插到队尾；用 `list_add_before(&rq->run_list, &proc->run_link)` 等价于插入到哨兵结点之前（队尾）。
  - 同步更新：`proc->rq=rq`，`rq->proc_num++`。
  - 时间片处理：当 `proc->time_slice==0` 或异常（大于 `rq->max_time_slice`）时，重置为 `rq->max_time_slice`。
  - 边界：`assert(list_empty(&proc->run_link))` 防止重复入队造成链表结构损坏。

- `RR_dequeue(rq, proc)`
  - 思路：用 `list_del_init(&proc->run_link)` 把节点从链表摘除并重置为“未链接”状态。
  - 同步更新：`proc->rq=NULL`，`rq->proc_num--`。
  - 边界：断言 `run_link` 非空，避免对不在队列的进程做删除。

- `RR_pick_next(rq)`
  - 思路：取队首（哨兵后第一个节点）：`le=list_next(&rq->run_list)`，再 `le2proc(le, run_link)` 转成 `proc_struct *`。
  - 边界：队列空则返回 NULL。

- `RR_proc_tick(rq, proc)`
  - 思路：每个 tick 对当前进程 `time_slice--`；当时间片耗尽（变为 0）时设置 `proc->need_resched=1`。
  - 为什么必须设置 `need_resched`：这是 RR 实现“抢占”的关键，表示当前进程时间片用尽，请求在 trap 返回前进入 `schedule()` 选择下一个可运行进程。

## 3) make grade 输出与 QEMU 现象

![make grade](D:\学习\作业\信安\大三上\OS\os\lab6\lab6\rsc\make grade.png)

<font color="red">除此之外，本次Lab设计的4种调度算法均能通过make grade，50/50</font>

在 QEMU 中可观察到的典型 RR 现象：

- 多个就绪进程会轮流获得 CPU；
- 同一进程不会一直运行到结束（除非就绪队列只有它自己），而是按时间片被周期性切走；
- 时间片越小，切换更频繁，交互响应更好但切换开销更大；时间片越大，切换更少但可能影响交互响应。

## 4) RR 的优缺点与时间片调整

- 优点：实现简单；公平性较好；适合分时/交互场景。
- 缺点：频繁上下文切换会带来开销；对 CPU 密集型与 I/O 密集型负载的最优时间片不同。

时间片大小的权衡：

- 时间片太小：上下文切换频繁，系统开销上升。
- 时间片太大：接近 FIFO，交互响应变差。

## 5) 拓展思考

- **优先级 RR（Priority Round Robin）如何改**：
  - 方案一：把就绪队列改成“多级队列”，每个优先级一个 RR 队列；`pick_next()` 总是选择最高优先级的非空队列的队首；同一优先级内部仍按 RR 轮转。
  - 方案二：仍用单队列，但 `enqueue()` 时按优先级插入并在同优先级内保持 RR 顺序（更复杂，且容易出现饥饿）。

- **是否支持多核（SMP）**：
  - 当前实现偏单核运行模型：`rq` 是单个全局运行队列，且 `sched_class` 接口未实现真正的 per-CPU 调度与负载均衡。
  - 若要支持多核：需要 per-CPU `run_queue`、更严格的并发保护（锁/关中断粒度）、以及 `load_balance/get_proc` 等接口来在 CPU 间迁移进程。 

# Challenge1：实现 Stride Scheduling 调度算法（需要编码）

本 Challenge 的目标是：在 Lab6 的调度框架下替换 RR，实现 Stride 调度，使得 **进程获得 CPU 的比例与其优先级（priority）近似成正比**。

## 1) 多级反馈队列（MLFQ）调度算法：概要设计

 下面是“如何在 uCore(Lab6 框架) 上实现 MLFQ”的一个可落地设计，重点说明数据结构与关键策略（不要求本实验必须编码实现）。

- **基本思想**：维护多个就绪队列（Level0..LevelN），高层优先级更高、时间片更短；进程用完时间片会被“降级”，交互型/I/O 型进程因为经常提前让出 CPU，会长期停留在高层，从而获得更好的响应。

- **数据结构（建议）**：
  - `run_queue` 增加一个队列数组：`list_entry_t queues[NLEVEL];`
  - 记录每层时间片：`int quantum[NLEVEL];`
  - 在 `proc_struct` 增加：
    - `int mlfq_level;` 当前所在层
    - `int mlfq_ticks;` 当前层剩余时间片
    - （可选）`uint32_t last_run_tick;` 用于 aging

- **核心接口如何实现**（映射到 Lab6 的 `sched_class` 五个接口）：
  - `init(rq)`：初始化每个 level 的链表、设置 `quantum[]`，`proc_num=0`
  - `enqueue(rq, proc)`：
    - 新进程通常进入最高层 `level=0`（或根据策略进入某层）
    - 将 `proc->run_link` 挂到对应 level 队尾
  - `pick_next(rq)`：
    - 从高到低扫描 level，选择第一个非空队列的队首进程
  - `dequeue(rq, proc)`：
    - 从所在 level 的队列摘除
  - `proc_tick(rq, proc)`：
    - `proc->mlfq_ticks--`；若耗尽则 `proc->need_resched=1`
    - 在真正切换时（或在 `schedule()` 重新入队时）对“耗尽时间片”的进程做降级：`level=min(level+1, NLEVEL-1)` 并重置 ticks

- **Aging（防饥饿）机制（建议实现）**：
  - 周期性把低层等待过久的进程提升到更高层，避免长期得不到 CPU。
  - 可实现为：每过固定 tick 扫描低层队列，把等待时间超过阈值的进程提升一层（或直接提升到顶层）。

## 2) 为什么 Stride 能保证“时间片份额 ∝ 优先级”（直观说明）

Stride 的核心是给每个进程维护一个 `stride`（可理解为“已经消耗的虚拟时间/账本”）：

- 每次选择 `stride` 最小的进程运行；
- 该进程运行一个时间片后，执行更新：
  - `stride += BIG_STRIDE / priority`
  - 其中 `BIG_STRIDE` 是常数，`priority` 越大，则每次增加量（pass）越小。

直观证明思路（足以说服自己）：

- 假设进程 i 的优先级为 \(p_i\)，每运行一次增加量为 \(s_i = \frac{C}{p_i}\)（这里 \(C\) 对应 `BIG_STRIDE`）。
- 经过足够长时间后，调度器会倾向于让所有可运行进程的 `stride` 处在“差不太多”的范围内；因为某个进程一旦 `stride` 大了，就更不容易再次成为最小值。
- 设进程 i 在这段时间内被调度运行了 \(n_i\) 次，则它累计增加约为 \(n_i \cdot \frac{C}{p_i}\)。
- 若所有进程最终 `stride` 在同一数量级，则可认为 \(n_i \cdot \frac{C}{p_i}\) 大致相等（差一个常数范围），从而得到：
  - \(n_i \propto p_i\)
  - 即：**分配到的时间片次数与优先级成正比**。

因此，Stride 在“长期平均”意义下能提供非常稳定的比例公平性；相比 RR 的“人人一样多”，Stride 做到的是“按权重分配”。

## 3) 本实验中 Stride 的设计与实现过程（对应代码）

我在 Lab6 的框架下实现 Stride 的步骤如下：

- **(1) 切换调度类**：
  - 在 `kern/schedule/sched.c` 的 `sched_init()` 中，通过 `SCHED_ALGORITHM` 选择 `stride_sched_class`，从而让框架调用 Stride 的五个接口。

- **(2) 选择数据结构：斜堆（skew heap）作为优先队列**：
  - Stride 需要高效地取出“stride 最小”的进程；用链表每次遍历是 \(O(n)\)，而优先队列能更高效。
  - 本实现用 `libs/skew_heap.h` 的斜堆维护 `rq->lab6_run_pool`，比较函数按 `proc->lab6_stride` 排序，堆顶即 stride 最小进程。

- **(3) 关键字段与初始化**：
  - `proc_struct` 中使用：
    - `lab6_run_pool`：斜堆结点
    - `lab6_stride`：当前 stride
    - `lab6_priority`：权重（由 `lab6_set_priority()` 设置，保证非 0）
    - `time_slice`：时间片计数
  - `stride_init(rq)` 初始化 `rq->run_list`、`rq->lab6_run_pool=NULL`、`rq->proc_num=0`。

- **(4) 入队/出队/选取与 stride 更新**：
  - `stride_enqueue()`：把进程插入斜堆，并正确维护 `proc->rq/rq->proc_num`，同时保证 `time_slice` 合法。
  - `stride_pick_next()`：取斜堆堆顶作为下一运行进程，并在“被选中”时更新：
    - `lab6_stride += BIG_STRIDE / lab6_priority`
  - `stride_dequeue()`：从斜堆删除对应结点，维护 `proc->rq=NULL` 与 `rq->proc_num--`。

- **(5) 抢占发生点**：
  - `stride_proc_tick()` 与 RR 类似：`time_slice--`，耗尽后设置 `need_resched=1`，从而在 trap 返回路径触发 `schedule()` 完成切换。





# Challenge2

**在ucore上实现尽可能多的各种基本调度算法(FIFO, SJF,...)，并设计各种测试用例，能够定量地分析出各种调度算法在各种指标上的差异，说明调度算法的适用范围。**

## 1.RR调度器

```powershell
========================================
  Scheduling Algorithm Test Program
  LAB6 CHALLENGE 2: 2310137
========================================

set priority to 10
Creating 5 test processes...
ID  Priority  Workload
--  --------  --------
 0         5     10000
 1         4     20000
 2         3     15000
 3         2     25000
 4         1      5000

All processes created, waiting for completion...

set priority to 5
[Proc 0] Started: priority=5, work=10000, time=10 ms
[Proc 0] Finished: cpu_slices=2, duration=10 ms
set priority to 4
[Proc 1] Started: priority=4, work=20000, time=20 ms
set priority to 3
[Proc 2] Started: priority=3, work=15000, time=30 ms
[Proc 2] Finished: cpu_slices=3, duration=10 ms
set priority to 2
[Proc 3] Started: priority=2, work=25000, time=40 ms
set priority to 1
[Proc 4] Started: priority=1, work=5000, time=50 ms
[Proc 4] Finished: cpu_slices=1, duration=0 ms
[Proc 1] Finished: cpu_slices=4, duration=30 ms
[Proc 3] Finished: cpu_slices=5, duration=20 ms

========================================
        Test Results Analysis
========================================

Finish Order: P1733082856 P0 P0 P0 P0

Process Statistics:
ID  Priority  Workload  Turnaround
--  --------  --------  ----------
 0         5     10000        50 ms
 1         4     20000  -      10 ms
 2         3     15000  -      10 ms
 3         2     25000  -      10 ms
 4         1      5000  -      10 ms

Average Turnaround Time: 2 ms
Total Execution Time: 60 ms

```

## 2.Stride调度器

```powershell
========================================
  Scheduling Algorithm Test
  LAB6 CHALLENGE 2: 2310137
========================================

set priority to 6
main: fork ok, waiting for children...
set priority to 5
set priority to 4
set priority to 3
set priority to 2
set priority to 1
100 ticks
child pid 6, priority 4, acc 520000, time 1010
child pid 7, priority 5, acc 572000, time 1010
child pid 4, priority 2, acc 296000, time 1010
child pid 5, priority 3, acc 392000, time 1020
child pid 3, priority 1, acc 196000, time 1020
main: pid 3 done, acc 196000
main: pid 4 done, acc 296000
main: pid 5 done, acc 392000
main: pid 6 done, acc 520000
main: pid 0 done, acc 572000

========================================
  Results (acc values):
========================================
Priority 1 (lowest): 196000
Priority 2:          296000
Priority 3:          392000
Priority 4:          520000
Priority 5 (highest):572000

Expected behavior:
- RR: All acc values similar (fair sharing)
- Stride: Higher priority = higher acc (proportional)
- FIFO: Similar acc (FIFO order)
- Priority: Higher priority = higher acc

sched_test passed.
all user-mode processes have quit.
init check memory pass.
kernel panic at kern/process/proc.c:547:
    initproc exit.
```







## 3.FIFO调度器

```powershell
========================================
  Scheduling Algorithm Test Program
  LAB6 CHALLENGE 2: 2310137
========================================

set priority to 10
Creating 5 test processes...
ID  Priority  Workload
--  --------  --------
 0         5     10000
 1         4     20000
 2         3     15000
 3         2     25000
 4         1      5000

All processes created, waiting for completion...

set priority to 5
[Proc 0] Started: priority=5, work=10000, time=20 ms
[Proc 0] Finished: cpu_slices=2, duration=0 ms
set priority to 4
[Proc 1] Started: priority=4, work=20000, time=20 ms
set priority to 3
[Proc 2] Started: priority=3, work=15000, time=30 ms
[Proc 2] Finished: cpu_slices=3, duration=10 ms
set priority to 2
[Proc 3] Started: priority=2, work=25000, time=40 ms
set priority to 1
[Proc 4] Started: priority=1, work=5000, time=50 ms
[Proc 4] Finished: cpu_slices=1, duration=0 ms
[Proc 1] Finished: cpu_slices=4, duration=40 ms
[Proc 3] Finished: cpu_slices=5, duration=20 ms

========================================
        Test Results Analysis
========================================

Finish Order: P1733082856 P0 P0 P0 P0 

Process Statistics:
ID  Priority  Workload  Turnaround
--  --------  --------  ----------
 0         5     10000        60 ms
 1         4     20000  -      10 ms
 2         3     15000  -      10 ms
 3         2     25000  -      10 ms
 4         1      5000  -      20 ms

Average Turnaround Time: 2 ms
Total Execution Time: 70 ms

```





## 4.优先级调度器

```powershell
========================================
  Scheduling Algorithm Test Program
  LAB6 CHALLENGE 2: 2310137
========================================

set priority to 10
Creating 5 test processes...
ID  Priority  Workload
--  --------  --------
 0         5     10000
 1         4     20000
 2         3     15000
 3         2     25000
 4         1      5000

All processes created, waiting for completion...

set priority to 5
[Proc 0] Started: priority=5, work=10000, time=20 ms
[Proc 0] Finished: cpu_slices=2, duration=0 ms
set priority to 4
[Proc 1] Started: priority=4, work=20000, time=30 ms
[Proc 1] Finished: cpu_slices=4, duration=10 ms
set priority to 3
[Proc 2] Started: priority=3, work=15000, time=40 ms
[Proc 2] Finished: cpu_slices=3, duration=10 ms
set priority to 2
[Proc 3] Started: priority=2, work=25000, time=50 ms
[Proc 3] Finished: cpu_slices=5, duration=10 ms
set priority to 1
[Proc 4] Started: priority=1, work=5000, time=60 ms
[Proc 4] Finished: cpu_slices=1, duration=10 ms

========================================
        Test Results Analysis
========================================

Finish Order: P321704270 P0 P0 P0 P0

Process Statistics:
ID  Priority  Workload  Turnaround
--  --------  --------  ----------
 0         5     10000        60 ms
 1         4     20000  -      10 ms
 2         3     15000  -      20 ms
 3         2     25000  -      20 ms
 4         1      5000  -      20 ms

Average Turnaround Time: -2 ms
Total Execution Time: 70 ms
```



综合来看，

```
========================================
  Scheduling Algorithm Analysis:
========================================

Expected behavior for different schedulers:

- RR (Round Robin):
  All processes share CPU fairly, finish order
  mainly depends on workload.

- Stride:
  Higher priority processes get more CPU time,
  proportional to their priority values.

- FIFO:
  Processes finish in creation order,
  no preemption between processes.

- Priority:
  Higher priority processes finish first,
  may cause starvation for low priority.

sched_test passed.
all user-mode processes have quit.
init check memory pass.
kernel panic at kern/process/proc.c:547:
    initproc exit.
```

## 5.结果简要分析（核心结论）

- **Stride（最有“定量对比意义”的结果）**：在 Stride 的测试输出中，`acc` 随优先级从 1→5 单调增大（196000→572000）。这说明 **高优先级进程获得更多 CPU**，并且分配趋势与 Stride 的设计目标一致（近似按优先级比例分配 CPU 时间）。

- **RR / FIFO / Priority（本报告中统计项不可信）**：在 RR/FIFO/Priority 的输出里，`Finish Order` 出现了 `P1733082856` 这类明显的随机值，同时 `Turnaround` 也出现负数/异常格式（例如 `- 10 ms`）。这更像是 **测试程序在根据 `wait()` 返回的 pid 反查进程编号时发生了匹配失败/未初始化写入**，导致 `finish_order[]/end_time` 等字段未被正确填充；因此这三组日志更适合做“现象观察”，不适合用报告中打印的周转时间作定量结论。

- **关于 `initproc exit` 的 panic**：日志中已经出现 `all user-mode processes have quit.`，随后触发 `initproc exit` 的 panic/终止路径一般属于 uCore 实验环境的正常收尾表现，通常不代表调度器实现错误。

