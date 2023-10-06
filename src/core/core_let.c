#include "core_includes.h"
#include "env.h"
#include "eval.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
// _let
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_let(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("let");

  REQUIRE(env, args, LENGTH(args) > 2,    "let requires a varlist and a body");
  
  ae_obj_t * const varlist = CAR(args);

  REQUIRE(env, args, PROPERP(varlist),    "varlist must be a proper list");
  REQUIRE(env, args, LENGTH(varlist) > 0, "empty varlist");

  FOR_EACH(varlist_item, varlist)
    REQUIRE(env, args,
            SYMBOLP(varlist_item) || (CONSP(varlist_item) && LENGTH(varlist_item) == 2),
            "varlist items must be symbols or lists with two elements");
  
  ae_obj_t * const body    = CDR(args);

  REQUIRE(env, args, PROPERP(body),       "body must be a proper list");
  REQUIRE(env, args, LENGTH(body) > 0,    "empty body");
  
  ae_obj_t * const new_env = NEW_ENV(env, NIL, NIL);

  FOR_EACH(varlist_item, varlist)
    ENV_SET_L(new_env,
              CAR(varlist_item), 
              SYMBOLP(CAR(varlist_item))
              ? NIL
              : EVAL(env, CDR(varlist)));

  ae_obj_t * ret           = ae_core_progn(new_env, body);
  
  CORE_RETURN("let", ret);
}
