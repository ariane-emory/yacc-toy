#pragma once

#include "ae_obj.h"
#include "ae_list.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
#define FOR_EACH_CORE(DO)                                                                          \
  DO(type)    /* GET_TYPE proxy */                                                                 \
  DO(body)    /* fun accessor */                                                                   \
  DO(params)  /* fun accessor */                                                                   \
  DO(syms)    /* env accessor */                                                                   \
  DO(vals)    /* env accessor */                                                                   \
  DO(parent)  /* env/fun accessor */                                                               \
  DO(numer)   /* rational/int accessor */                                                          \
  DO(denom)   /* rational/int accessor */                                                          \
  DO(msleep)                                                                                       \
  DO(properp) /* reduceable */                                                                     \
  DO(tailp)   /* reduceable */                                                                     \
  DO(length)  /* reduceable */                                                                     \
  DO(atomp)   /* reduceable */                                                                     \
  DO(car)                                                                                          \
  DO(cdr)                                                                                          \
  DO(cons)                                                                                         \
  DO(eq)                                                                                           \
  DO(eql)                                                                                          \
  DO(exit)                                                                                         \
  DO(not)     /* reduceable */                                                                     \
  DO(put)                                                                                          \
  /* probably, two out of these 3 could be reduced: */                                             \
  DO(princ)                                                                                        \
  DO(print)                                                                                        \
  DO(write)                                                                                        \
////////////////////////////////////////////////////////////////////////////////////////////////////
#define FOR_EACH_CORE_SPECIAL_FUN(DO)                                                              \
  DO(env)                                                                                          \
  DO(cond)                                                                                         \
  DO(eval)                                                                                         \
  DO(if)      /* reduceable */                                                                     \
  DO(lambda)                                                                                       \
  DO(macro)                                                                                        \
  DO(progn)                                                                                        \
  DO(quote)                                                                                        \
  DO(setq)                                                                                         \
////////////////////////////////////////////////////////////////////////////////////////////////////
#define FOR_EACH_MATH_OP(DO)                                                                       \
  DO(add, +, 0)                                                                                    \
  DO(sub, -, 0)                                                                                    \
  DO(mul, *, 1)                                                                                    \
  DO(div, /, 1)                                                                                    \
////////////////////////////////////////////////////////////////////////////////////////////////////
#define FOR_EACH_CMP_OP(DO)                                                                        \
  DO(equal,  ==, &=, true)                                                                         \
  DO(nequal, !=, |=, false)                                                                        \
  DO(lt,     < , &=, true)                                                                         \
  DO(lte,    <=, &=, true)                                                                         \
  DO(gt,     > , &=, true)                                                                         \
  DO(gte,    >=, &=, true)                                                                         \
////////////////////////////////////////////////////////////////////////////////////////////////////
#define DECL_CORE(name, ...) ae_obj_t * ae_core_##name  (ae_obj_t * const args);
////////////////////////////////////////////////////////////////////////////////////////////////////
FOR_EACH_MATH_OP(DECL_CORE);
FOR_EACH_CMP_OP(DECL_CORE);
FOR_EACH_CORE(DECL_CORE);
FOR_EACH_CORE_SPECIAL_FUN(DECL_CORE);
////////////////////////////////////////////////////////////////////////////////////////////////////
#define SETQ(env, sym, val) ae_core_setq(CONS(env, CONS(sym, LIST(val))))
// #define QUOTE(obj) ae_core_quote((obj))
