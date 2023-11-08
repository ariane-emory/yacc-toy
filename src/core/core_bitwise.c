#include "core_includes.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
// _bnot
////////////////////////////////////////////////////////////////////////////////////////////////////
ae_obj_t * ae_core_bnot(ae_obj_t * const env, ae_obj_t * const args, __attribute__((unused)) int args_length) {
  CORE_ENTER("bnot");
  REQUIRE(env, args, INTEGERP(CAR(args)));

  RETURN(NEW_INT(~INT_VAL(CAR(args))));
  
  CORE_EXIT("bnot");
}
////////////////////////////////////////////////////////////////////////////////////////////////////
