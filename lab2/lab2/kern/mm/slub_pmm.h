#ifndef __KERN_MM_SLUB_PMM_H__
#define __KERN_MM_SLUB_PMM_H__

#include <pmm.h>

extern const struct pmm_manager slub_pmm_manager;

// 对象级 SLUB 接口（使用固定大小类别进行小对象分配）
void *slub_malloc(size_t size);
void slub_free(void *ptr);

#endif /* !__KERN_MM_SLUB_PMM_H__ */
