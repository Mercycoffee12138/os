#ifndef __KERN_SCHEDULE_SCHED_RR_H__
#define __KERN_SCHEDULE_SCHED_RR_H__

#include <sched.h>

// RR (Round Robin) 时间片轮转调度
extern struct sched_class default_sched_class;

// Stride 步进调度
extern struct sched_class stride_sched_class;

// LAB6 CHALLENGE 2: 额外实现的调度算法
// FIFO (First In First Out) 先来先服务调度
extern struct sched_class FIFO_sched_class;

// Priority Scheduling 优先级调度
extern struct sched_class priority_sched_class;

#endif /* !__KERN_SCHEDULE_SCHED_RR_H__ */

