#include <defs.h>
#include <list.h>
#include <proc.h>
#include <assert.h>
#include <default_sched.h>

/*
 * FIFO (First In First Out) 调度算法
 * 
 * 算法特点：
 * - 先来先服务，按照进程到达顺序调度
 * - 非抢占式：进程一旦获得CPU，将一直运行直到完成或阻塞
 * - 在本实现中，为了配合ucore框架，仍使用时间片，但不会因时间片用完而抢占
 * 
 * 适用场景：
 * - 批处理系统
 * - 任务执行时间差异不大的场景
 * 
 * 缺点：
 * - 平均等待时间可能较长（护航效应：短作业等待长作业）
 * - 对交互式任务不友好
 * 
 * LAB6 CHALLENGE 2: 2310137
 */

/*
 * FIFO_init - 初始化运行队列
 */
static void
FIFO_init(struct run_queue *rq)
{
    list_init(&(rq->run_list));
    rq->proc_num = 0;
}

/*
 * FIFO_enqueue - 将进程加入队列尾部
 * FIFO按照到达顺序排队，新进程总是加到队尾
 */
static void
FIFO_enqueue(struct run_queue *rq, struct proc_struct *proc)
{
    assert(list_empty(&(proc->run_link)));
    // 插入到队列尾部（run_list之前）
    list_add_before(&(rq->run_list), &(proc->run_link));
    proc->rq = rq;
    rq->proc_num++;
    // FIFO不使用时间片抢占，设置一个很大的时间片
    // 进程会一直运行直到主动让出CPU或阻塞
    proc->time_slice = rq->max_time_slice;
}

/*
 * FIFO_dequeue - 从队列中移除进程
 */
static void
FIFO_dequeue(struct run_queue *rq, struct proc_struct *proc)
{
    assert(!list_empty(&(proc->run_link)));
    list_del_init(&(proc->run_link));
    rq->proc_num--;
}

/*
 * FIFO_pick_next - 选择队列头部的进程（最先到达的进程）
 */
static struct proc_struct *
FIFO_pick_next(struct run_queue *rq)
{
    if (list_empty(&(rq->run_list))) {
        return NULL;
    }
    // 获取队列头部（最先入队的进程）
    list_entry_t *le = list_next(&(rq->run_list));
    return le2proc(le, run_link);
}

/*
 * FIFO_proc_tick - 时钟中断处理
 * FIFO是非抢占式的，时钟中断不触发调度
 * 但为了让系统正常运行，当进程主动yield时仍需要调度
 */
static void
FIFO_proc_tick(struct run_queue *rq, struct proc_struct *proc)
{
    // FIFO非抢占：不因时间片耗尽而强制调度
    // 进程会一直运行直到完成、阻塞或主动yield
    // 这里什么都不做，让进程继续运行
}

struct sched_class FIFO_sched_class = {
    .name = "FIFO_scheduler",
    .init = FIFO_init,
    .enqueue = FIFO_enqueue,
    .dequeue = FIFO_dequeue,
    .pick_next = FIFO_pick_next,
    .proc_tick = FIFO_proc_tick,
};

