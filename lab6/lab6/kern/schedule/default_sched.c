#include <defs.h>
#include <list.h>
#include <proc.h>
#include <assert.h>
#include <default_sched.h>

/*
 * RR_init initializes the run-queue rq with correct assignment for
 * member variables, including:
 *
 *   - run_list: should be an empty list after initialization.
 *   - proc_num: set to 0
 *   - max_time_slice: no need here, the variable would be assigned by the caller.
 *
 * hint: see libs/list.h for routines of the list structures.
 */
static void
RR_init(struct run_queue *rq)
{
    // LAB6: 2310137
    // (1) 初始化rq->run_list为空链表
    // (2) 设置rq->proc_num为0
    list_init(&(rq->run_list));
    rq->proc_num = 0;
}

/*
 * RR_enqueue inserts the process ``proc'' into the tail of run-queue
 * ``rq''. The procedure should verify/initialize the relevant members
 * of ``proc'', and then put the ``run_link'' node into the queue.
 * The procedure should also update the meta data in ``rq'' structure.
 *
 * proc->time_slice denotes the time slices allocation for the
 * process, which should set to rq->max_time_slice.
 *
 * hint: see libs/list.h for routines of the list structures.
 */
static void
RR_enqueue(struct run_queue *rq, struct proc_struct *proc)
{
    // LAB6: 2310137
    // (1) 将进程的run_link插入到运行队列rq的队尾（使用list_add_before）
    // (2) 设置进程的rq指针指向当前运行队列
    // (3) 增加rq的proc_num计数
    // (4) 如果进程的时间片为0或超过最大值，重置为max_time_slice
    assert(list_empty(&(proc->run_link)));
    list_add_before(&(rq->run_list), &(proc->run_link));
    proc->rq = rq;
    rq->proc_num++;
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
        proc->time_slice = rq->max_time_slice;
    }
}

/*
 * RR_dequeue removes the process ``proc'' from the front of run-queue
 * ``rq'', the operation would be finished by the list_del_init operation.
 * Remember to update the ``rq'' structure.
 *
 * hint: see libs/list.h for routines of the list structures.
 */
static void
RR_dequeue(struct run_queue *rq, struct proc_struct *proc)
{
    // LAB6: 2310137
    // (1) 断言进程的run_link不为空（即进程在队列中）
    // (2) 使用list_del_init将进程从队列中删除并重新初始化run_link
    // (3) 清空进程的rq指针
    // (4) 减少rq的proc_num计数
    assert(!list_empty(&(proc->run_link)));
    list_del_init(&(proc->run_link));
    proc->rq = NULL;
    rq->proc_num--;
}

/*
 * RR_pick_next picks the element from the front of ``run-queue'',
 * and returns the corresponding process pointer. The process pointer
 * would be calculated by macro le2proc, see kern/process/proc.h
 * for definition. Return NULL if there is no process in the queue.
 *
 * hint: see libs/list.h for routines of the list structures.
 */
static struct proc_struct *
RR_pick_next(struct run_queue *rq)
{
    // LAB6: 2310137
    // (1) 如果运行队列为空，返回NULL
    // (2) 否则获取队列头部的进程（list_next获取run_list的下一个节点）
    // (3) 使用le2proc宏将list_entry转换为proc_struct指针
    if (list_empty(&(rq->run_list))) {
        return NULL;
    }
    list_entry_t *le = list_next(&(rq->run_list));
    return le2proc(le, run_link);
}

/*
 * RR_proc_tick works with the tick event of current process. You
 * should check whether the time slices for current process is
 * exhausted and update the proc struct ``proc''. proc->time_slice
 * denotes the time slices left for current process. proc->need_resched
 * is the flag variable for process switching.
 */
static void
RR_proc_tick(struct run_queue *rq, struct proc_struct *proc)
{
    // LAB6: 2310137
    // (1) 如果进程的时间片time_slice大于0，则递减
    // (2) 如果时间片减到0，设置need_resched为1，表示需要重新调度
    if (proc->time_slice > 0) {
        proc->time_slice--;
    }
    if (proc->time_slice == 0) {
        proc->need_resched = 1;
    }
}

struct sched_class default_sched_class = {
    .name = "RR_scheduler",
    .init = RR_init,
    .enqueue = RR_enqueue,
    .dequeue = RR_dequeue,
    .pick_next = RR_pick_next,
    .proc_tick = RR_proc_tick,
};
