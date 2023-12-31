#include <stdio.h>

#include "alist.h"

#include "list.h"
#include "write.h"
#include "log.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
// _set
////////////////////////////////////////////////////////////////////////////////////////////////////
ae_obj_t * ae_alist_set(ae_obj_t * list, ae_obj_t * const key, ae_obj_t * const value) {
#ifdef AE_LOG_KVP_SET_GET
  LOG(key,   "%s setting key", __func__);
  LOG(list,  "in list");
  LOG(value, "to value");
#endif
 
  assert(!list || TAILP(list));

  if (list == NULL)
    list = NIL;

  if (list != NIL)
    FOR_EACH(elem, list)
      if (EQL(CAR(elem), key)) {
        (CDR(elem) = value);
        goto end;
      }

  list = CONS(NEW_CONS(key, value), list);
  
end:

#ifdef AE_LOG_KVP_SET_GET
  LOG(key,   "after setting key");
  LOG(list, "list is");
  NL;
#endif

  return list;
}
////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////
// _contains_key
////////////////////////////////////////////////////////////////////////////////////////////////////
bool ae_alist_contains_key(ae_obj_t * const list, ae_obj_t * const key) {
#ifdef AE_LOG_KVP_HAS
  LOG(key,  "%s looking for key", __func__);
  LOG(list, "in list");
#endif

  if (list == NULL || list == NIL) 
    goto failed;
    
  FOR_EACH(elem, list)
    if (EQL(CAR(elem), key)) {
#ifdef AE_LOG_KVP_HAS
      LOG(key, "found key");
      NL;
#endif

      return true;
    }

failed:

#ifdef AE_LOG_KVP_HAS
  LOG(key, "did not find");
  NL;
#endif
  
  return false;
}
////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////
// _get
////////////////////////////////////////////////////////////////////////////////////////////////////
ae_obj_t * ae_alist_get(ae_obj_t * const list, ae_obj_t * const key) {
#ifdef AE_LOG_KVP_SET_GET
  LOG(key,  "%s looking for key", __func__);
  LOG(list, "in list");  
#endif

  if (list == NULL || list == NIL)
    goto failed;

  FOR_EACH(elem, list) {

#ifdef AE_LOG_KVP_SET_GET
    LOG(elem, "elem");
#endif
    
    if (EQL(CAR(elem), key)) {
#ifdef AE_LOG_KVP_SET_GET
      LOG(key,       "found key");
      LOG(CDR(elem), "with value");
      NL;
#endif

      return CDR(elem);
    }
  }
  
failed:

#ifdef AE_LOG_KVP_SET_GET
  LOG(key, "did not find");
  NL;
#endif

  return NIL;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
