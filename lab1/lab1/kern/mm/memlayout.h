#ifndef __KERN_MM_MEMLAYOUT_H__
#define __KERN_MM_MEMLAYOUT_H__

#define KSTACKPAGE          2                           // # of pages in kernel stack内核栈用的页数
#define KSTACKSIZE          (KSTACKPAGE * PGSIZE)       // sizeof kernel stack内核栈的总大小

#endif /* !__KERN_MM_MEMLAYOUT_H__ */

