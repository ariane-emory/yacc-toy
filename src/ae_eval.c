#include <stdio.h>

#include "ae_eval.h"
#include "ae_obj.h"
#include "ae_list.h"
#include "ae_env.h"

#define NL (putchar('\n'))
#define PR(...)  (fprintf(stdout, __VA_ARGS__))
#define ARRAY_SIZE(a) (sizeof(a) / sizeof((a)[0]))

////////////////////////////////////////////////////////////////////////////////////////////////////

static ae_obj_t * self(ae_obj_t * obj, ae_obj_t * env) {
  (void)env;
  return obj;
}

static ae_obj_t * lookup(ae_obj_t * sym, ae_obj_t * env) {
  return ENV_FIND(env, sym);
}

static ae_obj_t * apply(ae_obj_t * list, ae_obj_t * env) {
  (void)env;
  return ae_apply(CAR(list), env, CDR(list));
}

static const struct { ae_type_t type; ae_obj_t * (*handler)(ae_obj_t *, ae_obj_t *); }
eval_dispatch[] = {
  { AE_INTEGER,  &self           },
  { AE_RATIONAL, &self           },
  { AE_FLOAT,    &self           },
  { AE_INF,      &self           },
  { AE_CHAR,     &self           },
  { AE_STRING,   &self           },
  { AE_LAMBDA,   &self           },
  { AE_CORE_FUN, &self           },
  { AE_SYMBOL,   &lookup         },
  { AE_CONS,     &apply          },
};

static ae_obj_t * apply_core_fun(ae_obj_t * fun, ae_obj_t * env, ae_obj_t * args) {
#ifdef AE_LOG_EVAL
  PR("Apply:");
  PR("  fun  ");
  PUT(fun);
  NL;
  PR("  args ");
  WRITE(args);
  NL;
  PR("  env ");
  WRITE(env);
  NL;
#endif

  ae_obj_t * ret = NIL;

  if (SPECIAL_FUNP(fun)) {
    // special funs get their un-evaluated args, plus the env.

    ae_obj_t * env_and_args = CONS(env, CONS_NIL(args)); 
#ifdef AE_LOG_EVAL
    PR("Un-evaled args   ");
    WRITE(env_and_args);
    NL;
#endif

    ret = (*FUN_VAL(fun))(env_and_args);
  }
  else {
    ae_obj_t * evaled_args = NIL;
    
    FOR_EACH(elem,  args)
      PUSH(evaled_args, EVAL(env, elem));
    
#ifdef AE_LOG_EVAL
    PR("Evaled args   ");
    WRITE(evaled_args);
    NL;
#endif

    ret = (*FUN_VAL(fun))(evaled_args);
  }
  
#ifdef AE_LOG_EVAL
  PR("  ret ");
  WRITE(ret);
  NL;
#endif
  
  return ret;
}                                                                               
                                                                                
static ae_obj_t * apply_lambda  (ae_obj_t * fun, ae_obj_t * env, ae_obj_t * args) {
  (void)env, (void)fun, (void)args; assert(0); 
}

static const struct { ae_type_t type; ae_obj_t * (*handler)(ae_obj_t * fun, ae_obj_t * env, ae_obj_t * args); }
apply_dispatch[] = {
  { AE_CORE_FUN, &apply_core_fun },
  { AE_LAMBDA,   &apply_lambda   },
};

#define DISPATCH(table, obj, ...)                                                                  \
  for (size_t ix = 0; ix < ARRAY_SIZE(table); ix++)                                                \
    if (table[ix].type == GET_TYPE(obj))                                                           \
      return (*table[ix].handler)(obj, __VA_ARGS__);

ae_obj_t * ae_eval(ae_obj_t * env, ae_obj_t * obj) {
 #ifdef AE_LOG_EVAL
  PR("Eval ");
  WRITE(obj);
  PR(" in ");
  WRITE(env);
  NL;
#endif
  
  ASSERT_ENVP(env);
  DISPATCH(eval_dispatch, obj, env);
  fprintf(stderr, "Don't know how to eval a %s.\n", TYPE_STR(GET_TYPE(obj)));
  assert(0);
}

ae_obj_t * ae_apply(ae_obj_t * fun, ae_obj_t * env, ae_obj_t * args) {
#ifdef AE_LOG_EVAL
  PR("Apply ");
  WRITE(fun);
  PR(" to ");
  WRITE(args);
  NL;
#endif

  fun = EVAL(env, fun);
  
#ifdef AE_LOG_EVAL
  PR("Fun   ");
  PUT(fun);
  NL;
#endif

  ASSERT_FUNP(fun);
  ASSERT_TAILP(args);

  DISPATCH(apply_dispatch, fun, env, args);
  fprintf(stderr, "Don't know how to apply a %s.\n", TYPE_STR(GET_TYPE(fun)));
  assert(0);
}
