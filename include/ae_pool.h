#pragma once

////////////////////////////////////////////////////////////////////////////////////////////////////
// macros
////////////////////////////////////////////////////////////////////////////////////////////////////

#define DELOCATED(ptr)  ((pool_delocate_ptr(((struct ae_obj_t *)ptr))))
#define LOCATED(ptr)    ((pool_locate_ptr(((struct ae_obj_t *)ptr))))
#define DELOCATE(ptr)   ((ptr) = DELOCATED((ptr)))
#define LOCATE(ptr)     ((ptr) = LOCATED((ptr)))

////////////////////////////////////////////////////////////////////////////////////////////////////
// pool
////////////////////////////////////////////////////////////////////////////////////////////////////

extern const struct ae_obj_t * const pool_first;
extern const struct ae_obj_t * const pool_last;

struct ae_obj_t * pool_alloc_ae_obj();
void              pool_free_ae_obj(struct ae_obj_t * const this);
void              pool_print(void);
void              pool_clear(void);
struct ae_obj_t * pool_delocate_ptr(struct ae_obj_t * const ptr);
struct ae_obj_t * pool_locate_ptr(struct ae_obj_t * const ptr);
