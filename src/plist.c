#include <stdio.h>

#include "plist.h"

#include "list.h"
#include "write.h"
#include "log.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
// clone_list_up_to helper
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * clone_list_up_to(ae_obj_t * const pos, ae_obj_t * const list) {
  assert(pos);
  assert(list);
  assert(TAILP(list));
  
  ae_obj_t * new_list = NIL;
  ae_obj_t * tail     = NIL;
  
  for (ae_obj_t * cur = list; cur != pos; cur = CDR(cur)) {
    assert(! NILP(cur)); // If cur is NIL, then pos was not part of the list, which is an error.
      
    ae_obj_t * const new_elem = CONS(CAR(cur), NIL);

    if (new_list == NIL)
      new_list = new_elem;
    else
      CDR(tail) = new_elem;
    
    tail = new_elem;
  }
  
  return new_list;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _set_immutable
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_plist_set_immutable(ae_obj_t * const plist, ae_obj_t * const key, ae_obj_t * const value) {
    assert(plist && TAILP(plist) && (NILP(plist) || !(LENGTH(plist) % 2)));
    assert(key && value);

    if (NILP(plist)) {
        return CONS(key, CONS(value, NIL));
    }

    ae_obj_t * dummy_head = CONS(NIL, NIL);
    ae_obj_t * tail = dummy_head;
    
    for (ae_obj_t * pos = plist; !NILP(pos); pos = CDR(CDR(pos))) {
        if (EQL(CAR(pos), key)) {
            CDR(tail) = CONS(key, CONS(value, CDR(CDR(pos))));
            break;
        }
        CDR(tail) = CONS(CAR(pos), CONS(CADR(pos), NIL));
        tail = CDR(tail);
    }

    if (NILP(CDR(tail))) {
        CDR(tail) = CONS(key, CONS(value, NIL));
    }

    ae_obj_t * new_plist = CDR(dummy_head);
    return new_plist;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _set_mutable
////////////////////////////////////////////////////////////////////////////////////////////////////
void ae_plist_set_mutable(ae_obj_t * const plist, ae_obj_t * const key, ae_obj_t * const value) {
  assert(plist);
  assert(CONSP(plist));
  assert(!(LENGTH(plist) % 2));
  assert(key);
  assert(value);
  
  for (ae_obj_t * pos = plist; pos != NIL; pos = CDR(CDR(pos)))
    if (EQL(CAR(pos), key)) {
      CADR(pos) = value;

      return; 
    }

  ae_obj_t * const new_tail = CONS(CAR(plist), CONS(CADR(plist), CDR(CDR(plist))));
  CAR(plist) = key;
  CDR(plist) = CONS(value, new_tail);
}


////////////////////////////////////////////////////////////////////////////////////////////////////
// _set_internal
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_plist_set_internal(ae_obj_t * const plist, ae_obj_t * const key, ae_obj_t * const value) {
    if (plist == NULL || plist == NIL) {
        // Use the immutable version if the list is empty
        // as this will create a new list with the key-value pair.
        return ae_plist_set_immutable(NIL, key, value);
    } else {
        // Use the mutable version to update the existing list.
        ae_plist_set_mutable(plist, key, value);
        return plist; // Return the updated plist.
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
// _set
////////////////////////////////////////////////////////////////////////////////////////////////////
ae_obj_t * ae_plist_set(ae_obj_t * list, ae_obj_t * const key, ae_obj_t * const value) {
#ifdef AE_LOG_KVP_SET_GET
  LOG(key,   "%s setting key", __func__);
  LOG(list,  "in list");
  LOG(value, "to value");
#endif
  
  assert(!list || (TAILP(list) && ! (LENGTH(list) % 2)));
  
  if (list == NULL)
    list = NIL;

  if (list != NIL)
    for (ae_obj_t * position = list; position != NIL; position = CDR(CDR(position))) {
      ae_obj_t    * elem1    = CAR(position);
      ae_obj_t    * elem2    = position ? CADR(position) : NIL;
      
      if (EQL(elem1, key)) {
        CADR(position) = value;

        goto end;
      }
    }

  list = CONS(key, CONS(value, list));

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
bool ae_plist_contains_key(ae_obj_t * const list, ae_obj_t * const key) {
#ifdef AE_LOG_KVP_HAS
  LOG(key,  "%s looking for key", __func__);
  LOG(list, "in list");
#endif

  if (list == NULL || list == NIL)
    goto failed;

  for (ae_obj_t * position = list;
       position && position != NIL;
       position  = CDR(CDR(position)))
    if (EQL(CAR(position), key)) {
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
ae_obj_t * ae_plist_get(ae_obj_t * const list, ae_obj_t * const key) {
#ifdef AE_LOG_KVP_SET_GET
  LOG(key,  "%s looking for key", __func__);
  LOG(list, "in list");
#endif

  if (list == NULL || list == NIL)
    goto failed;

  for (ae_obj_t * position = list;
       position && position != NIL;
       position  = CDR(CDR(position))) {

    assert(CDR(CDR(position)));
    
    ae_obj_t     * elem1 = CAR(position);
    ae_obj_t     * elem2 = position ? CADR(position) : NIL;

#ifdef AE_LOG_KVP_SET_GET
    LOG(position, "position");
    LOG(elem1,    "elem1");
    if (elem2)
      LOG(elem2,  "elem2");
#endif
    
    if (EQL(CAR(position), key)) {
#ifdef AE_LOG_KVP_SET_GET
      LOG(key,   "found key");
      LOG(elem2, "with value");
      NL;
#endif

      return elem2;
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
