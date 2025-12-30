#include <defs.h>
#include <list.h>
#include <proc.h>
#include <assert.h>
#include <default_sched.h>

/*
 * Priority Scheduling (优先级调度算法)
 * 
 * 算法特点：
 * - 按照进程优先级调度，优先级高的进程先执行
 * - 使用lab6_priority字段作为优先级（值越大优先级越高）
 * - 本实现是抢占式的：使用时间片，时间片用完后重新调度
 * 
 * 适用场景：
 * - 需要区分任务重要性的系统
 * - 实时系统（配合适当的优先级分配策略）
 * 
 * 缺点：
 * - 可能导致饥饿（低优先级进程长时间得不到执行）
 * - 需要合理设置优先级
 * 
 * LAB6 CHALLENGE 2: 2310137
 */

/*
 * priority_init - 初始化运行队列
 */
static void
priority_init(struct run_queue *rq)
{
    list_init(&(rq->run_list));
    rq->proc_num = 0;
}

/*
 * priority_enqueue - 将进程加入队列
 * 按优先级从高到低排序插入，保持队列有序
 */
static void
priority_enqueue(struct run_queue *rq, struct proc_struct *proc)
{
    assert(list_empty(&(proc->run_link)));
    
    // 按优先级顺序插入（优先级高的在前）
    list_entry_t *le = &(rq->run_list);
    while ((le = list_next(le)) != &(rq->run_list)) {
        struct proc_struct *p = le2proc(le, run_link);
        // 如果当前进程优先级更高，插入到这个位置之前
        if (proc->lab6_priority > p->lab6_priority) {
            break;
        }
    }
    // 插入到le之前
    list_add_before(le, &(proc->run_link));
    
    proc->rq = rq;
    rq->proc_num++;
    
    // 设置时间片
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
        proc->time_slice = rq->max_time_slice;
    }
}

/*
 * priority_dequeue - 从队列中移除进程
 */
static void
priority_dequeue(struct run_queue *rq, struct proc_struct *proc)
{
    assert(!list_empty(&(proc->run_link)));
    list_del_init(&(proc->run_link));
    rq->proc_num--;
}

/*
 * priority_pick_next - 选择优先级最高的进程
 * 由于队列已按优先级排序，直接取队首即可
 */
static struct proc_struct *
priority_pick_next(struct run_queue *rq)
{
    if (list_empty(&(rq->run_list))) {
        return NULL;
    }
    // 队首就是优先级最高的进程
    list_entry_t *le = list_next(&(rq->run_list));
    return le2proc(le, run_link);
}

/*
 * priority_proc_tick - 时钟中断处理
 * 与RR类似，时间片用完后触发重新调度
 */
static void
priority_proc_tick(struct run_queue *rq, struct proc_struct *proc)
{
    if (proc->time_slice > 0) {
        proc->time_slice--;
    }
    if (proc->time_slice == 0) {
        proc->need_resched = 1;
    }
}

struct sched_class priority_sched_class = {
    .name = "priority_scheduler",
    .init = priority_init,
    .enqueue = priority_enqueue,
    .dequeue = priority_dequeue,
    .pick_next = priority_pick_next,
    .proc_tick = priority_proc_tick,
};

