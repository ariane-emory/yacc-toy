#include <stdbool.h>
#include <stdio.h>

#include "eval.h"
#include "obj.h"
#include "alist.h"
#include "plist.h"
#include "list.h"
#include "env.h"
#include "util.h"
#include "write.h"
#include "free_list.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
// Macros
////////////////////////////////////////////////////////////////////////////////////////////////////

#define GET_DISPATCH(row, table, obj)                                                              \
  for (size_t ix = 0; ix < ARRAY_SIZE(table); ix++)                                                \
    if (table[ix].type == GET_TYPE(obj)) {                                                         \
      row = table[ix];                                                                             \
                                                                                                   \
      break;                                                                                       \
    }

////////////////////////////////////////////////////////////////////////////////////////////////////
// ae_eval_args, refactoring in progress
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_eval_args(ae_obj_t * const env, ae_obj_t * const args) {
  NIL_IF_NILP(args);

  int args_count = LENGTH(args);
  
  if (log_eval)
    LOG(args, "evaluating fun's %d arg%s:", LENGTH(args), s_or_blank(args_count));

  INDENT;

  ae_obj_t * current_arg = args;
  ae_obj_t * result_head = NIL; // Initialized to NULL now
  ae_obj_t * result_tail = NIL;
  int ctr = 0;
  
  while (! ATOMP(current_arg)) {
    ++ctr;

    if (log_eval)
      LOG(CAR(current_arg), "eval   arg #%d/%d", ctr, args_count);

    INDENT;

    ae_obj_t* eval_result = EVAL(env, CAR(current_arg));

    OUTDENT;

    if (log_eval)
      LOG(eval_result, "evaled arg #%d/%d", ctr, args_count);

    if (NILP(result_head)) {
      result_head = NEW_CONS(eval_result, NIL);
      result_tail = result_head;
    } else {
      CDR(result_tail) = NEW_CONS(eval_result, NIL);
      result_tail = CDR(result_tail);
    }

    current_arg = CDR(current_arg);
  }

  if (! NILP(current_arg)) {
    if (log_eval)
      LOG(current_arg, "eval   tail arg");

    INDENT;

    ae_obj_t* eval_result = EVAL(env, current_arg);

    OUTDENT;

    if (log_eval)
      LOG(eval_result, "evaled tail arg");

    if (NILP(result_head))
      result_head = eval_result;
    else
      CDR(result_tail) = eval_result;
  }

  OUTDENT;
  
  if (log_eval)
    LOG(result_head, "evaluated fun's %d arg%s:", LENGTH(args), s_or_blank(LENGTH(args)));

  return result_head;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// data
////////////////////////////////////////////////////////////////////////////////////////////////////

bool log_eval = false;
bool log_macro = false;

////////////////////////////////////////////////////////////////////////////////////////////////////
// _apply dispatch handlers
////////////////////////////////////////////////////////////////////////////////////////////////////

//==================================================================================================
// apply core funs
//==================================================================================================

static ae_obj_t * apply_core(ae_obj_t * env, ae_obj_t * fun, ae_obj_t * args) {

#ifndef AE_NO_ARG_COUNT_CHECK
  bool invalid_args_length = false;
  int args_length          = LENGTH(args);
  
  if      (CORE_MIN_ARGS(fun) != 15 && LENGTH(args) < (int)CORE_MIN_ARGS(fun))
    invalid_args_length = true;
  else if (CORE_MAX_ARGS(fun) != 15 && LENGTH(args) > (int)CORE_MAX_ARGS(fun))
    invalid_args_length = true;

  if (invalid_args_length) {
    char * msg_tmp = free_list_malloc(256);

    LOG(args, "invalid arg count:");
    
    // if CORE_MIN_ARGS(fun) == 15, then it has no minimum number of args, generate an appropriate message:
    if (CORE_MIN_ARGS(fun) == 15 && CORE_MAX_ARGS(fun) != 15)
      sprintf(msg_tmp, "%s:%d: core '%s' requires at most %d args, but got %d",
              __FILE__,
              __LINE__,
              CORE_NAME(fun),
              CORE_MAX_ARGS(fun),
              LENGTH(args));
    else if (CORE_MAX_ARGS(fun) == 15 && CORE_MIN_ARGS(fun) != 15)
      sprintf(msg_tmp, "%s:%d: core '%s' requires at least %d args, but got %d",
              __FILE__,
              __LINE__,
              CORE_NAME(fun),
              CORE_MIN_ARGS(fun),
              LENGTH(args));
    else if (CORE_MAX_ARGS(fun) == CORE_MIN_ARGS(fun))
      sprintf(msg_tmp, "%s:%d: core '%s' requires %d arg%s, but got %d",
              __FILE__,
              __LINE__,
              CORE_NAME(fun),
              CORE_MIN_ARGS(fun),
              s_or_blank(CORE_MIN_ARGS(fun)),
              LENGTH(args));
    else
      sprintf(msg_tmp, "%s:%d: core '%s' requires %d to %d args, but got %d",
              __FILE__,
              __LINE__,
              CORE_NAME(fun),
              CORE_MIN_ARGS(fun),
              CORE_MAX_ARGS(fun),
              LENGTH(args));

    char * msg = free_list_malloc(strlen(msg_tmp) + 1);
    strcpy(msg, msg_tmp);
    free_list_free(msg_tmp);
    
    ae_obj_t * err_data = NIL;

    KSET(err_data, KW("env"),  env);
    KSET(err_data, KW("args"), args);
    KSET(err_data, KW("fun"),  fun);

    return NEW_ERROR(msg, err_data);
  }
#endif

  if (! SPECIALP(fun)) {
    args = EVAL_ARGS(env, args);
    
    if (log_eval)
      LOG(args, "applying core fun '%s' to %d evaled arg%s:", CORE_NAME(fun), LENGTH(args), s_or_blank(LENGTH(args)));
  }
  else if (log_eval) {
    LOG(args, "applying core fun '%s' to %d unevaled arg%s:", CORE_NAME(fun), LENGTH(args), s_or_blank(LENGTH(args)));
  }
       
  ae_obj_t * ret = (*CORE_FUN(fun))(env, args, args_length);

  //log_column = log_column_default; // end of apply core
  
  if (log_eval)
    LOG(ret, "applying core fun '%s' returned %s :%s", CORE_NAME(fun), a_or_an(GET_TYPE_STR(ret)), GET_TYPE_STR(ret));

  return ret;
}

//==================================================================================================
// apply lambda fun
//==================================================================================================

static ae_obj_t * apply_user(ae_obj_t * env, ae_obj_t * fun, ae_obj_t * args) {
  assert(LAMBDAP(fun) || MACROP(fun));

  if (CONSP(FUN_PARAMS(fun)) && LENGTH(args) < LENGTH(FUN_PARAMS(fun))) {
    char * msg_tmp = free_list_malloc(256);
    char * fun_desc = SWRITE(fun);
    
    sprintf(msg_tmp, "%s:%d: user fun '%s' requires %s %d arg%s, but got %d",
            __FILE__,
            __LINE__,
            fun_desc,
            ! PROPERP(FUN_PARAMS(fun)) ? "at least" : "exactly",
            LENGTH(FUN_PARAMS(fun)),
            s_or_blank(LENGTH(FUN_PARAMS(fun))),
            LENGTH(args));

    free(fun_desc);
    
    char * msg = free_list_malloc(strlen(msg_tmp) + 1);
    strcpy(msg, msg_tmp);
    free_list_free(msg_tmp);

    ae_obj_t * err_data = NIL;

    KSET(err_data, KW("env"),  env);
    KSET(err_data, KW("args"), args);
    KSET(err_data, KW("fun"),  fun);
  }
  
  if (! SPECIALP(fun)) {
    args = EVAL_ARGS(env, args);
    
    if (log_eval)
      LOG(args, "applying user fun to %d evaled arg%s:", LENGTH(args), s_or_blank(LENGTH(args)));
  }
  else if (log_eval) {
    LOG(args, "applying user fun to %d unevaled arg%s:", LENGTH(args), s_or_blank(LENGTH(args)));
  }
  
  ae_obj_t * body    = FUN_BODY(fun);

  env = NEW_ENV(FUN_ENV(fun), FUN_PARAMS(fun), args);
  // env = NEW_ENV(env, FUN_PARAMS(fun), args);

  if (log_eval) {
    LOG(env,           "new env for user fun:");
    LOG(ENV_SYMS(env), "new env's syms:");
    LOG(ENV_VALS(env), "new env's vals:");
  }
  
  if (log_eval) {
    char * tmp = SWRITE(fun);
    LOG(ENV_VALS(env),            "applying user fun %s to %d arg%s", tmp, LENGTH(ENV_VALS(env)), s_or_blank(LENGTH(ENV_VALS(env))));
    free(tmp);
  }
  
  INDENT;
  
  if (log_eval) {
    // If FUN_PARAMS(fun) is a blob, we lie to get a plural length:
    LOG(FUN_PARAMS(fun), "with param%s", s_or_blank(CONSP(FUN_PARAMS(fun)) ? LENGTH(FUN_PARAMS(fun)) : 2));
    LOG(body,            "with body");
  }

#ifdef AE_DEBUG_OBJ
  DSET(env, "fun", fun);
#endif

  ae_obj_t * result = EVAL(env, body);

  // log_column = log_column_default; // end of apply user
  
  OUTDENT;

  if (log_eval)
    LOG(result, "applying user fun returned %s :%s", a_or_an(GET_TYPE_STR(result)), GET_TYPE_STR(result));

  return result;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _apply
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * apply(ae_obj_t * env, ae_obj_t * obj) {
  assert(CONSP(obj)); // should return an ERROR instead?

  ae_obj_t * fun  = CAR(obj);
  ae_obj_t * args = CDR(obj);

  assert(TAILP(args));

  if (log_eval) {
    char * tmp = SWRITE(fun);
    LOG(obj,  "evaluate list by applying '%s' to %d arg%s:", tmp, LENGTH(args), s_or_blank(LENGTH(args)));

    free (tmp);
  }

  INDENT;

  if (log_eval)
    LOG(env,  "in env");

  ae_obj_t * head = fun;

  fun = EVAL(env, fun);

  if (! (COREP(fun) || LAMBDAP(fun) || MACROP(fun))) {
    NL;
    LOG(head, "Result of evaluating head: ");
    LOG(fun,  "is inapplicable object: ");
    SLOGF("with type: %s", GET_TYPE_STR(fun));
    NL;

    /* This assert should be replaced by returning an ERROR obj: */

    assert(0);
  }

  if (MACROP(fun) && (log_eval || log_macro))
    LOG(obj, "expanding");

  ae_obj_t * ret = COREP(fun)
    ? apply_core(env, fun, args)
    : apply_user(env, fun, args);

  if (MACROP(fun)) {
    /* do some replacey stuff here.  */
    /* this is new and might be kind of suss. */

    if (log_eval || log_macro)
      LOG(ret, "expansion");

    if (CONSP(ret)) {
      CAR(obj) = CAR(ret);
      CDR(obj) = CDR(ret);
    }
    else {
      CAR(obj) = SYM("progn");
      CDR(obj) = CONS(ret, NIL);
    }

    if (!CONSP(ret) && (log_eval || log_macro))
      LOG(obj, "polished expansion");

    ret  = EVAL(env, obj);

    if (log_eval || log_macro)
      LOG(ret, "evaled  expansion");

    *obj = *ret;
  }

#if AE_TRACK_ORIGINS_DURING_EVAL // in apply
  if (! DHAS(ret, "birth-place")) {
    DSET(ret, "birth-place", env);

    if (log_eval)
      LOG(ret, "birthed");
  }

  if (! DHAS(ret, "origin"))
    DSET(ret, "origin", fun);
#endif

  if (ERRORP(ret)) {
    FPRINT(fun, stderr);
    FPR(stderr, " returned an error: ");
    FWRITE(ret, stderr);
    
    // exit(1); /* STOP! */
    
    if (EHAS(ret, "fun"))
      ESET(ret, "fun", CONS(fun, EGET(ret, "fun")));
    else
      ESET(ret, "fun", CONS(fun, NIL));

    return ret;
  }

  OUTDENT;

  if (log_eval)
    LOG(ret, "evaluating list returned %s :%s", a_or_an(GET_TYPE_STR(ret)), GET_TYPE_STR(ret));
  
  static int ctr = 0;

  if (log_column > log_column_default) {
    if (++ctr > 3) {
      ctr = 0;
      log_column -= log_tab_width;
      if (log_column < log_column_default)
        log_column = log_column_default; // end of apply
    }
  }
  else {
    ctr = 0;
  }
    
  return ret;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// other _eval dispatch handlers
////////////////////////////////////////////////////////////////////////////////////////////////////

static ae_obj_t * self(ae_obj_t * env, ae_obj_t * obj) {
  (void)env;

#if AE_TRACK_ORIGINS_DURING_EVAL // in self
  if (! DHAS(obj, "birth-place")) {
    DSET(obj, "birth-place", env);

    if (log_eval)
      LOG(obj, "birthed");
  }

  if (! DHAS(obj, "origin"))
    DSET(obj, "origin", KW("self-evaluated"));
#endif

  if (log_eval)
    LOG(obj, "self-evaluated %s :%s", a_or_an(GET_TYPE_STR(obj)), GET_TYPE_STR(obj));

  return obj;
}

static ae_obj_t * lookup(ae_obj_t * env, ae_obj_t * sym) {
  bool bound = ENV_BOUNDP(env, sym);

  ae_obj_t * ret = NIL;

  if (! bound) {
    ae_obj_t * err_data = NIL;
    KSET(err_data, KW("env"), env);
    KSET(err_data, KW("unbound-symbol"), sym);

    char * tmp = free_list_malloc(256);
    sprintf(tmp, "%s:%d: unbound symbol '%s'", __FILE__, __LINE__, SYM_VAL(sym));
    char * msg = free_list_malloc(strlen(tmp) + 1);
    strcpy(msg, tmp);
    
    ret = NEW_ERROR(msg, err_data);

    goto end;
  }

  ret = KEYWORDP(sym)
    ? sym
    : ENV_FIND(env, sym);

#if AE_TRACK_ORIGINS_DURING_EVAL // in lookup
  if (! DHAS(ret, "birth-place")) {
    DSET(ret, "birth-place", env);

    if (log_eval)
      LOG(ret, "birthed");
  }

  if (! DHAS(ret, "origin"))
    DSET(ret, "origin", KW("lookup"));
#endif

  if (log_eval)
    LOG(ret, "looked up '%s' and found %s :%s", SYM_VAL(sym), a_or_an(GET_TYPE_STR(ret)), GET_TYPE_STR(ret));

end:
  return ret;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _eval dispatch table
////////////////////////////////////////////////////////////////////////////////////////////////////

typedef struct {
  ae_type_t type;
  ae_obj_t * (*handler)(ae_obj_t *, ae_obj_t *);
} eval_dispatch_row_t;

static const eval_dispatch_row_t eval_dispatch_table[] = {
  { AE_CONS,     &apply,  },
  { AE_SYMBOL,   &lookup, },
  { AE_INTEGER,  &self,   },
  { AE_CORE,     &self,   },
  { AE_LAMBDA,   &self,   },
  { AE_MACRO,    &self,   },
  { AE_STRING,   &self,   },
  { AE_ENV,      &self,   },
  { AE_ERROR,    &self,   },
  { AE_CHAR,     &self,   },
  { AE_FLOAT,    &self,   },
  { AE_RATIONAL, &self,   },
};

////////////////////////////////////////////////////////////////////////////////////////////////////
// _eval
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_eval(ae_obj_t * env, ae_obj_t * obj) {
  NIL_IF_NILP(obj);
  
  assert(env);
  assert(obj);
  assert(ENVP(env));

  eval_dispatch_row_t dispatch = { 0 };

  GET_DISPATCH(dispatch, eval_dispatch_table, obj);

  assert(*dispatch.handler);

  ae_obj_t * ret = (*dispatch.handler)(env, obj);

  return ret;
}
