#include "core_includes.h"
#include "env.h"
#include "eval.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
// _let
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_let(ae_obj_t * const env, ae_obj_t * const args, __attribute__((unused)) int args_length) {
  CORE_BEGIN("let");

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

  int ctr = 0;
  
  FOR_EACH(varlist_item, varlist) {
    ctr++;
    
    if (log_core) 
      LOG(varlist_item, "let varlist item #%d/%d", ctr, LENGTH(varlist));
    
    INDENT;
    
    ae_obj_t * val =
      SYMBOLP(varlist_item)
      ? NIL
      : EVAL(env, CADR(varlist_item));


    if (log_core) {
      if (SYMBOLP(varlist_item))
        LOG(varlist_item, "binding symbol");
      else 
        LOG(CAR(varlist_item), "binding symbol");
   
      LOG(val,               "to value");   
    }

    ENV_SET_L(new_env,
              CAR(varlist_item), 
              val);

    OUTDENT;
  }

  if (log_core) {
    LOG(ENV_SYMS(new_env), "new_env syms");
    LOG(ENV_VALS(new_env), "new_env vals");
  }

  ae_obj_t * ret           = ae_core_progn(new_env, body, LENGTH(body));
  
  CORE_RETURN("let", ret);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _let_star
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_let_star(ae_obj_t * const env, ae_obj_t * const args, __attribute__((unused)) int args_length) {
  CORE_BEGIN("let_star");

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

  int ctr = 0;
  
  FOR_EACH(varlist_item, varlist) {
    ctr++;

    if (log_core)
      LOG(varlist_item, "let* varlist item #%d/%d", ctr, LENGTH(varlist));

    INDENT;
    
    if (log_core)
      OLOG(varlist_item);

    ae_obj_t * val =
      SYMBOLP(varlist_item)
      ? NIL
      : EVAL(new_env, CADR(varlist_item));

    if (log_core) {
      if (SYMBOLP(varlist_item))
        LOG(varlist_item, "binding symbol");
      else 
        LOG(CAR(varlist_item), "binding symbol");
   
      LOG(val,               "to value");   
    }
    
    ENV_SET_L(new_env,
              CAR(varlist_item), 
              val);

    OUTDENT;
  }

  if (log_core) {
    LOG(ENV_SYMS(new_env), "new_env syms");
    LOG(ENV_VALS(new_env), "new_env vals");
  }

  ae_obj_t * ret           = ae_core_progn(new_env, body, LENGTH(body));
  
  CORE_RETURN("let_star", ret);
}
