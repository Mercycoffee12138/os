#include <defs.h>
#include <list.h>
#include <proc.h>
#include <assert.h>
#include <default_sched.h>
#include <stdio.h>

#define USE_SKEW_HEAP 1

/* You should define the BigStride constant here*/
/* LAB6 CHALLENGE 1: 2310137 */
/* BIG_STRIDE应该是一个足够大的值，使得stride差值在int32_t范围内能正确比较
 * 选择0x7FFFFFFF (2^31-1)，这是int32_t的最大值
 * 这样可以确保两个stride的差值不会溢出有符号32位整数的表示范围
 */
#define BIG_STRIDE 0x7FFFFFFF

/* The compare function for two skew_heap_node_t's and the
 * corresponding procs*/
static int
proc_stride_comp_f(void *a, void *b)
{
     struct proc_struct *p = le2proc(a, lab6_run_pool);
     struct proc_struct *q = le2proc(b, lab6_run_pool);
     int32_t c = p->lab6_stride - q->lab6_stride;
     if (c > 0)
          return 1;
     else if (c == 0)
          return 0;
     else
          return -1;
}

/*
 * stride_init initializes the run-queue rq with correct assignment for
 * member variables, including:
 *
 *   - run_list: should be a empty list after initialization.
 *   - lab6_run_pool: NULL
 *   - proc_num: 0
 *   - max_time_slice: no need here, the variable would be assigned by the caller.
 *
 * hint: see libs/list.h for routines of the list structures.
 */
static void
stride_init(struct run_queue *rq)
{
     /* LAB6 CHALLENGE 1: 2310137
      * (1) init the ready process list: rq->run_list
      * (2) init the run pool: rq->lab6_run_pool
      * (3) set number of process: rq->proc_num to 0
      */
     list_init(&(rq->run_list));
     rq->lab6_run_pool = NULL;
     rq->proc_num = 0;
}

/*
 * stride_enqueue inserts the process ``proc'' into the run-queue
 * ``rq''. The procedure should verify/initialize the relevant members
 * of ``proc'', and then put the ``lab6_run_pool'' node into the
 * queue(since we use priority queue here). The procedure should also
 * update the meta date in ``rq'' structure.
 *
 * proc->time_slice denotes the time slices allocation for the
 * process, which should set to rq->max_time_slice.
 *
 * hint: see libs/skew_heap.h for routines of the priority
 * queue structures.
 */
static void
stride_enqueue(struct run_queue *rq, struct proc_struct *proc)
{
     /* LAB6 CHALLENGE 1: 2310137
      * (1) insert the proc into rq correctly
      * NOTICE: you can use skew_heap or list. Important functions
      *         skew_heap_insert: insert a entry into skew_heap
      *         list_add_before: insert  a entry into the last of list
      * (2) recalculate proc->time_slice
      * (3) set proc->rq pointer to rq
      * (4) increase rq->proc_num
      */
#if USE_SKEW_HEAP
     // 使用斜堆实现优先级队列
     // 先初始化堆节点，确保状态干净
     proc->lab6_run_pool.left = proc->lab6_run_pool.right = proc->lab6_run_pool.parent = NULL;
     rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, 
                                          &(proc->lab6_run_pool), 
                                          proc_stride_comp_f);
#else
     // 使用链表实现
     list_add_before(&(rq->run_list), &(proc->run_link));
#endif
     // 设置时间片：如果时间片为0或超过最大值，重置为max_time_slice
     if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
          proc->time_slice = rq->max_time_slice;
     }
     // 确保 priority 至少为1，防止后续除零
     if (proc->lab6_priority == 0) {
          proc->lab6_priority = 1;
     }
     proc->rq = rq;
     rq->proc_num++;
}

/*
 * stride_dequeue removes the process ``proc'' from the run-queue
 * ``rq'', the operation would be finished by the skew_heap_remove
 * operations. Remember to update the ``rq'' structure.
 *
 * hint: see libs/skew_heap.h for routines of the priority
 * queue structures.
 */
static void
stride_dequeue(struct run_queue *rq, struct proc_struct *proc)
{
     /* LAB6 CHALLENGE 1: 2310137
      * (1) remove the proc from rq correctly
      * NOTICE: you can use skew_heap or list. Important functions
      *         skew_heap_remove: remove a entry from skew_heap
      *         list_del_init: remove a entry from the  list
      */
#if USE_SKEW_HEAP
     // 从斜堆中移除进程
     rq->lab6_run_pool = skew_heap_remove(rq->lab6_run_pool, 
                                          &(proc->lab6_run_pool), 
                                          proc_stride_comp_f);
#else
     // 从链表中移除进程
     list_del_init(&(proc->run_link));
#endif
     proc->rq = NULL;
     rq->proc_num--;
}
/*
 * stride_pick_next pick the element from the ``run-queue'', with the
 * minimum value of stride, and returns the corresponding process
 * pointer. The process pointer would be calculated by macro le2proc,
 * see kern/process/proc.h for definition. Return NULL if
 * there is no process in the queue.
 *
 * When one proc structure is selected, remember to update the stride
 * property of the proc. (stride += BIG_STRIDE / priority)
 *
 * hint: see libs/skew_heap.h for routines of the priority
 * queue structures.
 */
static struct proc_struct *
stride_pick_next(struct run_queue *rq)
{
     /* LAB6 CHALLENGE 1: 2310137
      * (1) get a  proc_struct pointer p  with the minimum value of stride
             (1.1) If using skew_heap, we can use le2proc get the p from rq->lab6_run_pool
             (1.2) If using list, we have to search list to find the p with minimum stride value
      * (2) update p's stride value: p->lab6_stride
      * (3) return p
      */
#if USE_SKEW_HEAP
     // 斜堆的根节点就是stride最小的进程
     if (rq->lab6_run_pool == NULL) {
          return NULL;
     }
     struct proc_struct *p = le2proc(rq->lab6_run_pool, lab6_run_pool);
#else
     // 遍历链表找到stride最小的进程
     if (list_empty(&(rq->run_list))) {
          return NULL;
     }
     list_entry_t *le = list_next(&(rq->run_list));
     struct proc_struct *p = le2proc(le, run_link);
     // 遍历找最小stride
     while ((le = list_next(le)) != &(rq->run_list)) {
          struct proc_struct *q = le2proc(le, run_link);
          if (proc_stride_comp_f(&(q->lab6_run_pool), &(p->lab6_run_pool)) < 0) {
               p = q;
          }
     }
#endif
     // 更新stride值: stride += BIG_STRIDE / priority
     // priority为0时当作1处理，防止除零错误
     if (p->lab6_priority == 0) {
          p->lab6_stride += BIG_STRIDE;
     } else {
          p->lab6_stride += BIG_STRIDE / p->lab6_priority;
     }
     return p;
}

/*
 * stride_proc_tick works with the tick event of current process. You
 * should check whether the time slices for current process is
 * exhausted and update the proc struct ``proc''. proc->time_slice
 * denotes the time slices left for current
 * process. proc->need_resched is the flag variable for process
 * switching.
 */
static void
stride_proc_tick(struct run_queue *rq, struct proc_struct *proc)
{
     /* LAB6 CHALLENGE 1: 2310137
      * 时钟中断处理，与RR相同
      * (1) 如果进程的时间片time_slice大于0，则递减
      * (2) 如果时间片减到0，设置need_resched为1，表示需要重新调度
      */
     if (proc->time_slice > 0) {
          proc->time_slice--;
     }
     if (proc->time_slice == 0) {
          proc->need_resched = 1;
     }
}

struct sched_class stride_sched_class = {
    .name = "stride_scheduler",
    .init = stride_init,
    .enqueue = stride_enqueue,
    .dequeue = stride_dequeue,
    .pick_next = stride_pick_next,
    .proc_tick = stride_proc_tick,
};
