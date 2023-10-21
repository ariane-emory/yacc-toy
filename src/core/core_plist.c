#include "core_includes.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
// _pset
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_pset(__attribute__((unused)) ae_obj_t * const env,
                        ae_obj_t * const args,
                        __attribute__((unused)) int args_length) {
  CORE_BEGIN("pset");

  ae_obj_t * key   = CAR(args);
  ae_obj_t * value = CADR(args); // this could be unsafe if value is NIL, maybe.
  ae_obj_t * obj   = CADDR(args);
  ae_obj_t * plist = DOBJ(obj);

  CORE_RETURN("pset", PSET(plist, key, value));
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _pget
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_pget(__attribute__((unused)) ae_obj_t * const env,
                        ae_obj_t * const args,
                        __attribute__((unused)) int args_length) {
  CORE_BEGIN("pget");

  ae_obj_t * key   = CAR(args);
  ae_obj_t * obj   = CADR(args);
  ae_obj_t * plist = DOBJ(obj);

  CORE_RETURN("pget", PGET(plist, key));
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _phas
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_phas(__attribute__((unused)) ae_obj_t * const env,
                        ae_obj_t * const args,
                        __attribute__((unused)) int args_length) {
  CORE_BEGIN("phas");

  ae_obj_t * key   = CAR(args);
  ae_obj_t * obj   = CADR(args);
  ae_obj_t * plist = DOBJ(obj);

  CORE_RETURN("phas", TRUTH(PHAS(plist, key)));
}

