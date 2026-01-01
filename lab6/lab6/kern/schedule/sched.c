#include <list.h>
#include <sync.h>
#include <proc.h>
#include <sched.h>
#include <stdio.h>
#include <assert.h>
#include <default_sched.h>

/*
 * LAB6 CHALLENGE 2: 调度算法选择
 * 通过修改SCHED_ALGORITHM宏来切换不同的调度算法
 * 可选值：
 *   0 - RR (Round Robin) 时间片轮转
 *   1 - Stride 步进调度
 *   2 - FIFO 先来先服务
 *   3 - Priority 优先级调度
 */
#define SCHED_ALGORITHM 0  // 默认使用Stride调度器

// the list of timer
static list_entry_t timer_list;

static struct sched_class *sched_class;

static struct run_queue *rq;

static inline void
sched_class_enqueue(struct proc_struct *proc)
{
    if (proc != idleproc)
    {
        sched_class->enqueue(rq, proc);
    }
}

static inline void
sched_class_dequeue(struct proc_struct *proc)
{
    sched_class->dequeue(rq, proc);
}

static inline struct proc_struct *
sched_class_pick_next(void)
{
    return sched_class->pick_next(rq);
}

void sched_class_proc_tick(struct proc_struct *proc)
{
    if (proc != idleproc)
    {
        sched_class->proc_tick(rq, proc);
    }
    else
    {
        proc->need_resched = 1;
    }
}

static struct run_queue __rq;

void sched_init(void)
{
    list_init(&timer_list);

    // LAB6 CHALLENGE 2: 根据SCHED_ALGORITHM选择调度算法
#if SCHED_ALGORITHM == 0
    sched_class = &default_sched_class;     // RR调度器
#elif SCHED_ALGORITHM == 1
    sched_class = &stride_sched_class;      // Stride调度器
#elif SCHED_ALGORITHM == 2
    sched_class = &FIFO_sched_class;        // FIFO调度器
#elif SCHED_ALGORITHM == 3
    sched_class = &priority_sched_class;    // 优先级调度器
#else
    sched_class = &default_sched_class;     // 默认使用RR
#endif

    rq = &__rq;
    rq->max_time_slice = MAX_TIME_SLICE;
    sched_class->init(rq);

    cprintf("sched class: %s\n", sched_class->name);
}

void wakeup_proc(struct proc_struct *proc)
{
    assert(proc->state != PROC_ZOMBIE);
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE)
        {
            proc->state = PROC_RUNNABLE;
            proc->wait_state = 0;
            if (proc != current)
            {
                sched_class_enqueue(proc);
            }
        }
        else
        {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}

void schedule(void)
{
    bool intr_flag;
    struct proc_struct *next;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
        if (current->state == PROC_RUNNABLE)
        {
            sched_class_enqueue(current);
        }
        if ((next = sched_class_pick_next()) != NULL)
        {
            sched_class_dequeue(next);
        }
        if (next == NULL)
        {
            next = idleproc;
        }
        next->runs++;
        if (next != current)
        {
            proc_run(next);
        }
    }
    local_intr_restore(intr_flag);
}
