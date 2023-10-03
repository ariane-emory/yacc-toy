#include "ae_list.h"
#include "ae_alist.h"
#include "ae_util.h"

ae_obj_t * ae_alist_set(ae_obj_t ** const alist, ae_obj_t * const key, ae_obj_t * const value) {
  if (*(ae_obj_t **)alist)
    *alist = NIL;
  
  FOR_EACH(elem, *alist)    
    if (CAR(elem) == key) {
      CDR(elem) = value;
      return *alist;
    }
  
  return *alist = CONS(NEW_CONS(key, value), *alist);
}
 
ae_obj_t * ae_alist_get(ae_obj_t ** const alist, ae_obj_t * const key) {
  if (*(ae_obj_t **)alist)
    *alist = NIL;
  
  FOR_EACH(elem, alist)
    if (CAR(elem) == key)
      return CDR(elem);
  
  return NIL; 
}

bool ae_alist_contains_key(ae_obj_t ** const alist, ae_obj_t * const key) {
  if (*(ae_obj_t **)alist)
    return NIL;
  
  FOR_EACH(elem, alist)
    if (CAR(elem) == key)
      return true;
  
  return false; 
}

