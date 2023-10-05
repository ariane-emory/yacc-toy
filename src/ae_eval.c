#include <stdio.h>

#include "ae_eval.h"
#include "ae_obj.h"
#include "ae_alist.h"
#include "ae_plist.h"
#include "ae_list.h"
#include "ae_env.h"
#include "ae_util.h"
#include "ae_write.h"
#include "ae_free_list.h"
#include "require.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
// Macros
////////////////////////////////////////////////////////////////////////////////////////////////////

#define GET_DISPATCH(row, table, obj)                                                              \
  for (size_t ix = 0; ix < ARRAY_SIZE(table); ix++)                                                \
    if (table[ix].type == GET_TYPE(obj)) {                                                         \
      row = table[ix];                                                                             \
      break;                                                                                       \
    }

#ifdef AE_LOG_EVAL
#  define MAYBE_EVAL(special, args)                                                                \
  if (! special && CAR(args)) {                                                                    \
    ae_obj_t * evaled_args = NIL;                                                                  \
    LOG(args, "evaluating fun's %d arg%s:", LENGTH(args), s_or_blank(LENGTH(args)));               \
    INDENT;                                                                                        \
    FOR_EACH(elem, args)                                                                           \
    {                                                                                              \
      ae_obj_t * tmp = EVAL(env, elem);                                                            \
      PUSH(evaled_args, tmp);                                                                      \
    }                                                                                              \
    args = evaled_args;                                                                            \
    OUTDENT;                                                                                       \
    LOG(args, "evaluated fun's %d arg%s:", LENGTH(args), s_or_blank(LENGTH(args)));                \
  }                                                                                                
#else
#  define MAYBE_EVAL(special, args)                                                                \
  if (! special && CAR(args)) {                                                                    \
    ae_obj_t * evaled_args = NIL;                                                                  \
    INDENT;                                                                                        \
    FOR_EACH(elem, args)                                                                           \
    {                                                                                              \
      ae_obj_t * tmp = EVAL(env, elem);                                                            \
      PUSH(evaled_args, tmp);                                                                      \
    }                                                                                              \
    args = evaled_args;                                                                            \
    OUTDENT;                                                                                       \
  }                                                                                                
#endif

////////////////////////////////////////////////////////////////////////////////////////////////////
// _apply dispatch handlers
////////////////////////////////////////////////////////////////////////////////////////////////////

//==================================================================================================
// apply core funs
//==================================================================================================

static ae_obj_t * apply_core(ae_obj_t * env, ae_obj_t * fun, ae_obj_t * args) {
/* #ifdef AE_LOG_EVAL */
/*   LOG(args, "applying core '%s' to %d evaluated args:", CORE_NAME(fun), LENGTH(args)); */
/* #endif */

#ifdef AE_CORE_ENVS
  env = NEW_ENV(env, NIL, NIL);
  LOG(env, "new env for core fun '%s':", CORE_NAME(fun));
#  ifdef AE_DEBUG_OBJ
  DSET(env, "fun", fun);
#  endif
#endif

#if defined(AE_DEBUG_OBJ) && defined(AE_LOG_EVAL)
  //LOG(DOBJ(env), "with this debug data");
#endif

  MAYBE_EVAL(SPECIALP(fun), args);

#ifdef AE_LOG_EVAL
  /* if (SPECIALP(fun)) */
  /*   printf("YES YES YES\n"); */
  /* else */
  /*   printf("NO NO NO\n"); */
  
  if (! SPECIALP(fun)) {
    LOG(args, "applying core fun '%s' to %d evaluated arg%s:", CORE_NAME(fun), LENGTH(args), s_or_blank(LENGTH(args)));
  }
  else {
    LOG(args, "applying core fun '%s' to %d unevaluated arg%s:", CORE_NAME(fun), LENGTH(args), s_or_blank(LENGTH(args)));
  }
#endif

#ifdef AE_LOG_EVAL
  // INDENT;
#endif

  ae_obj_t * ret = (*CORE_FUN(fun))(env, args);
  
#ifdef AE_LOG_EVAL
// OUTDENT;
  LOG(ret, "applying core fun '%s' returned %s :%s", CORE_NAME(fun), a_or_an(GET_TYPE_STR(ret)), GET_TYPE_STR(ret));
#endif

  return ret;
}

//==================================================================================================
// apply lambda fun
//==================================================================================================

static ae_obj_t * apply_user(ae_obj_t * env, ae_obj_t * fun, ae_obj_t * args) {
  (void)env;

  ae_obj_t * body    = CONS(SYM("progn"), FUN_BODY(fun));

#ifndef AE_NO_SINGLE_SYM_PARAMS
  if (SYMBOLP(FUN_PARAMS(fun))
      && (! NILP(FUN_PARAMS(fun)))
  ) {
    env = NEW_ENV(FUN_ENV(fun), CONS(FUN_PARAMS(fun), NIL), CONS(args, NIL));
    LOG(env, "new env for user fun:");
  }
  else
#endif
//    env = NEW_ENV(FUN_ENV(fun), FUN_PARAMS(fun), args);
  {
    env = NEW_ENV(env, FUN_PARAMS(fun), args);
    LOG(env, "new env for user fun:");
  }

#ifdef AE_LOG_EVAL
  /* LOG(env,              "user fun will be applied in new env:"); */
  /* INDENT; */
  /* LOG(ENV_SYMS(env),    "new env symbols"); */
  /* LOG(ENV_VALS(env),    "new env values"); */
  /* LOG(body,             "new env body"); */
  /* OUTDENT; */
#endif

#ifdef AE_LOG_EVAL
  char * tmp = SWRITE(fun);
  LOG(args,            "applying user fun %s to %d args", tmp, LENGTH(args));
  free(tmp);
  INDENT;
  // LOG(args,            "apply user fun to args");
  // LOG(env,             "in env");
  LOG(FUN_PARAMS(fun), "with params");
  LOG(body,            "with body");
#endif

#ifdef AE_DEBUG_OBJ
  DSET(env, "fun", fun);

#  ifdef AE_LOG_EVAL
  // LOG(DOBJ(env), "with this debug data");
#  endif
#endif

  ae_obj_t * result = EVAL(env, body);
  // result = SPECIALP(fun) ? EVAL(env, result) : result;

#ifdef AE_LOG_EVAL
  OUTDENT;

  LOG(result, "applying user fun returned %s :%s", a_or_an(GET_TYPE_STR(result)), GET_TYPE_STR(result));
  // LOG_RETURN_WITH_TYPE("apply user fun", result);
#endif

  return result;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _apply dispatch table
////////////////////////////////////////////////////////////////////////////////////////////////////

typedef struct {
  ae_type_t type;
  ae_obj_t * (*handler)(ae_obj_t *, ae_obj_t *, ae_obj_t *);
  bool special;
  bool replaces;
} apply_dispatch_row_t;

static const apply_dispatch_row_t apply_dispatch_table[] = {
  { AE_CORE,   &apply_core, true,  false  }, // 3rd field may be ignored internally by apply_core.
  { AE_LAMBDA, &apply_user, false, false },
  { AE_MACRO,  &apply_user, true,  true  },
};

////////////////////////////////////////////////////////////////////////////////////////////////////
// _apply
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * apply(ae_obj_t * env, ae_obj_t * obj) {
  assert(CONSP(obj)); // should return an ERROR instead?

  log_column = log_column_default;

  ae_obj_t * fun  = CAR(obj);
  ae_obj_t * args = CDR(obj);

#ifdef AE_LOG_EVAL
  char * tmp = SWRITE(fun);
  LOG(obj,  "evaluate list by applying '%s' to %d args:", tmp, LENGTH(args));
  free (tmp);

  INDENT;
  // LOG(args, "to args");
  LOG(env,  "in env");
#endif

  fun = EVAL(env, fun);

  if (! (COREP(fun) || LAMBDAP(fun) || MACROP(fun))) {
    LOG(fun, "Not applicable: ");

    /* This assert should be replaced by returning an ERROR obj: */

    assert(0);
  }

  assert(TAILP(args));

  apply_dispatch_row_t dispatch = {0};

  GET_DISPATCH(dispatch, apply_dispatch_table, fun);

#ifdef AE_LOG_EVAL
  /* const char * type_str = TYPE_STR(dispatch.type); */
  /* /\* *\/ char * tmp      = free_list_malloc(strlen(type_str) + 2); */
  /* sprintf(tmp, ":%s",     type_str); */
  /* ae_obj_t   * sym      = SYM(tmp); */

  /* LOG(sym, "dispatch to application for"); */

  /* free_list_free(tmp); */
#endif

  MAYBE_EVAL(dispatch.special, args);

  ae_obj_t * ret = dispatch.special
    ? (*dispatch.handler)(env, fun, args)
    : (*dispatch.handler)(env, fun, args);

#if AE_TRACK_ORIGINS_DURING_EVAL // in apply
  if (! DHAS(ret, "birth-place")) {
    DSET(ret, "birth-place", env);

#  ifdef AE_LOG_EVAL
    LOG(ret, "birthed");
#  endif
  }

  if (! DHAS(ret, "origin")) {
    DSET(ret, "origin", fun);
  }
#endif


  if ( ERRORP(ret)) {
    if (EHAS(ret, "fun")) {
#ifdef AE_CALLSTACK_IS_PROPER
      ESET(ret, "fun", CONS(fun, EGET(ret, "fun")));
#else
      ESET(ret, "fun", NEW_CONS(fun, EGET(ret, "fun")));
#endif
    }
    else {
#ifdef AE_CALLSTACK_IS_PROPER
      ESET(ret, "fun", CONS(fun, NIL));
#else
      ESET(ret, "fun", fun);
#endif
    }
  }

  /* if (dispatch.replaces) { */
  /*   if (CONSP(obj)) {       */
  /*     LOG(obj, "[REPLACING]"); */
  /*     INDENT; */
  /*     LOG(ret, "with "); */
  /*     OUTDENT; */

  /*     ret = UNSAFE_MOVE(obj, ret); */
  /*   } */
  /*   else { */
  /*     ret = UNSAFE_MOVE(obj, CONS(SYM("progn"), CONS(ret, NIL))); */
  /*   } */
  /* } */

#ifdef AE_LOG_EVAL
 OUTDENT;

 LOG(ret, "evaluating list returned %s :%s", a_or_an(GET_TYPE_STR(ret)), GET_TYPE_STR(ret));
#endif

 //log_column = log_column_default;

  return ret;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// other _eval dispatch handlers
////////////////////////////////////////////////////////////////////////////////////////////////////

static ae_obj_t * self(ae_obj_t * env, ae_obj_t * obj) {
  (void)env;

#ifdef AE_LOG_EVAL
  // LOG (obj, "[eval by returning self]");

  // LOG_RETURN_WITH_TYPE("self", obj);
#endif

#if AE_TRACK_ORIGINS_DURING_EVAL // in self
  if (! DHAS(obj, "birth-place")) {
    DSET(obj, "birth-place", env);

#  ifdef AE_LOG_EVAL
    LOG(obj, "birthed");
#  endif
  }

  if (! DHAS(obj, "origin")) {
    DSET(obj, "origin", KW("self-evaluated"));
  }
#endif

#ifdef AE_LOG_EVAL
  LOG(obj, "self-evaluated %s :%s", a_or_an(GET_TYPE_STR(obj)), GET_TYPE_STR(obj));
  // LOG(obj, "[self-evaluated %s :%s]", a_or_an(GET_TYPE_STR(obj)), GET_TYPE_STR(obj));
#endif

  return obj;
}

static ae_obj_t * lookup(ae_obj_t * env, ae_obj_t * sym) {
#ifdef AE_LOG_EVAL
  // LOG(sym, "[eval by looking up]");

  // INDENT;
#endif

  ae_obj_t * ret = KEYWORDP(sym)
    ? sym
    : ENV_FIND(env, sym);

#if AE_TRACK_ORIGINS_DURING_EVAL // in lookup
  if (! DHAS(ret, "birth-place")) {
    DSET(ret, "birth-place", env);

#  ifdef AE_LOG_EVAL
    LOG(ret, "birthed");
#  endif
  }

  if (! DHAS(ret, "origin")) {
    DSET(ret, "origin", KW("lookup"));
  }
#endif

#ifdef AE_LOG_EVAL
  // OUTDENT;
  LOG(ret, "looked up '%s' and found %s :%s", SYM_VAL(sym), a_or_an(GET_TYPE_STR(ret)), GET_TYPE_STR(ret));
#endif

  return ret;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _eval dispatch table
////////////////////////////////////////////////////////////////////////////////////////////////////

typedef struct {
  ae_type_t type;
  ae_obj_t * (*handler)(ae_obj_t *, ae_obj_t *);
  bool replaces; // probably remove.
} eval_dispatch_row_t;

static const eval_dispatch_row_t eval_dispatch_table[] = {
  { AE_CONS,     &apply,  false },
  { AE_SYMBOL,   &lookup, false },
  { AE_CORE,     &self,   false },
  { AE_LAMBDA,   &self,   false },
  { AE_MACRO,    &self,   true  },
  { AE_STRING,   &self,   false },
  { AE_INTEGER,  &self,   false },
  { AE_ENV,      &self,   false },
  { AE_ERROR,    &self,   false },
  { AE_CHAR,     &self,   false },
  { AE_FLOAT,    &self,   false },
  { AE_RATIONAL, &self,   false },
};

////////////////////////////////////////////////////////////////////////////////////////////////////
// _eval
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_eval(ae_obj_t * env, ae_obj_t * obj) {
  assert(ENVP(env));

  //log_column = log_column_default;

  eval_dispatch_row_t dispatch = {0};

  GET_DISPATCH(dispatch, eval_dispatch_table, obj);

#ifdef AE_LOG_EVAL
  {
    /* LOG(obj, "[eval]"); */
    /* INDENT; */
    /* LOG(env, "in env"); */

   /*  const char * type = GET_TYPE_STR(obj); */
   /*  /\* *\/ char * tmp  = free_list_malloc(strlen(type) + 2); */
   /*  sprintf(tmp, ":%s", type); */
   /*  ae_obj_t   * sym  = SYM(tmp); */

   /*  LOG(sym, "dispatch to eval for"); */

    /* free_list_free(tmp); */
  }
#endif

  assert(*dispatch.handler);

  ae_obj_t * ret = (*dispatch.handler)(env, obj);

/* #if AE_DEBUG_OBJ */
/*   if (! DHAS(ret, "birth-place")) */
/*     DSET(ret, "birth-place", env); */

/* #  ifdef AE_LOG_EVAL */
/*   LOG(ret, "birthed");   */
/* #  endif */
/* #endif */

#ifdef AE_LOG_EVAL
  // OUTDENT;

  // LOG_RETURN_WITH_TYPE("eval", ret);
#endif

  return ret;
}
