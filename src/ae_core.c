#include <stdbool.h>
#include <unistd.h>

#include "ae_alist.h"
#include "ae_core.h"
#include "ae_env.h"
#include "ae_eval.h"
#include "ae_free_list.h"
#include "ae_list.h"
#include "ae_obj.h"
#include "ae_util.h"
#include "ae_write.h"
#include "require.h"

////////////////////////////////////////////////////////////////////////////////////////////////////

#ifdef AE_LOG_CORE
#  define CORE_BEGIN(name)                                                                           \
  SLOG("[core " name "]");                                                                       \
  LOG(args, name " args");                                                                         \
  LOG(env,  name " body");                                                                             \
  INDENT;                                                                                             
#else
#  define CORE_BEGIN(name) ((void)0)
#endif

#  define CORE_RETURN(name, val) \
 OUTDENT;       \
 LOG(val, "[core " name " rtrning]"); \
 return val;



////////////////////////////////////////////////////////////////////////////////////////////////////
// math
////////////////////////////////////////////////////////////////////////////////////////////////////

// This only deals with AE_INTEGERS for now. It mutates its first argument.
#define DEF_MATH_OP(name, oper, default)                                                           \
ae_obj_t * ae_core_ ## name(ae_obj_t * const env, ae_obj_t * const args) {                         \
  CORE_BEGIN(#name);                                                                               \
  assert(CONSP(args));                                                                             \
                                                                                                   \
  ae_obj_t * accum = NIL;                                                                          \
  ae_obj_t * rest  = NIL;                                                                          \
                                                                                                   \
  if (NILP(CDR(args))) {                                                                           \
    accum = NEW_INT(default);                                                                      \
    rest = args;                                                                                   \
  }                                                                                                \
  else {                                                                                           \
    REQUIRE(env, args, INTEGERP(CAR(args)));                                                       \
                                                                                                   \
    accum = CAR(args);                                                                             \
    rest  = CDR(args);                                                                             \
  }                                                                                                \
                                                                                                   \
  FOR_EACH(elem, rest) {                                                                           \
    REQUIRE(env, args, INTEGERP(elem));                                                            \
    /* INT_VAL(accum) = INT_VAL(accum) oper INT_VAL(elem); */                                      \
    accum = NEW_INT(INT_VAL(accum) oper INT_VAL(elem));                                            \
  }                                                                                                \
                                                                                                   \
  CORE_RETURN(#name, accum);                                                                       \
}

FOR_EACH_CORE_MATH_OP(DEF_MATH_OP);

////////////////////////////////////////////////////////////////////////////////////////////////////
// numeric comparison
////////////////////////////////////////////////////////////////////////////////////////////////////

// This only deals with AE_INTEGERS for now.
#define DEF_CMP_OP(name, oper, assign, init)                                                       \
ae_obj_t * ae_core_ ## name(ae_obj_t * const env, ae_obj_t * const args) {                         \
  CORE_BEGIN(#name);                                                                                 \
  assert(CONSP(args));                                                                             \
                                                                                                   \
  bool result = init;                                                                              \
                                                                                                   \
  FOR_EACH(elem, args) {                                                                           \
    if (NILP(CDR(position)))                                                                       \
        break;                                                                                     \
                                                                                                   \
    REQUIRE(env, args, INTEGERP(elem));                                                            \
    REQUIRE(env, args, INTEGERP(CADR(position)));                                                  \
                                                                                                   \
    result assign INT_VAL(elem) oper INT_VAL(CADR(position));                                      \
  }                                                                                                \
                                                                                                   \
  CORE_RETURN(#name, TRUTH(result));                                                                \
}

FOR_EACH_CORE_CMP_OP(DEF_CMP_OP);

////////////////////////////////////////////////////////////////////////////////////////////////////
// _aset
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_aset(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("aset");
  
  int len = LENGTH(args);

  REQUIRE(env, args, len >= 2, "aset requires at least 2 args");
  REQUIRE(env, args, len <= 3, "aset requires 2 or 3 args");

  ae_obj_t * alist = CAR(args);
  ae_obj_t * key   = CADR(args);
  ae_obj_t * value = CADDR(args);

  REQUIRE(env, args, SYMBOLP(key));

  CORE_RETURN("aset", ASET(alist, key, value));
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _aget
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_aget(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("aget");
  
  int len = LENGTH(args);
  
  REQUIRE(env, args, len == 2, "aget requires 2 args");

  ae_obj_t * alist = CAR(args);
  ae_obj_t * key   = CADR(args);

  REQUIRE(env, args, SYMBOLP(key));

  CORE_RETURN("aget", AGET(alist, key));
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _ahas
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_ahas(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("ahas");
  
  int len = LENGTH(args);

  REQUIRE(env, args, len == 2, "aget requires 2 args");

  ae_obj_t * alist = CAR(args);
  ae_obj_t * key   = CADR(args);

  REQUIRE(env, args, SYMBOLP(key));

  CORE_RETURN("ahas", TRUTH(AHAS(alist, key)));
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _setq
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_setq(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("setq");

  int len = LENGTH(args);
  
  REQUIRE(env, args, len >= 1, "setq requires at least 1 arg");
  REQUIRE(env, args, len <= 2, "setq requires 1 or 2 args");
  
  ae_obj_t * sym         = CAR(args);
  ae_obj_t * val         = CADR(args);

  REQUIRE(env, args, SYMBOLP(sym));
  REQUIRE(env, args, sym != NIL,  "can't set nil");
  REQUIRE(env, args, sym != TRUE, "can't set t");
  
#ifdef AE_CORE_BEGIN
  LOG(sym, "core setq sym");
  LOG(val, "core setq val");
#endif

  val                    = EVAL(env, val);

  ENV_SET(env, sym, val);

  CORE_RETURN("setq", val);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _progn
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_progn(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("progn");
  
  ae_obj_t * ret = NIL;

  FOR_EACH(elem, args)
    ret = EVAL(env, elem);

  CORE_RETURN("progn", ret);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _properp
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_properp(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("properp");

  REQUIRE(env, args, LENGTH(args) == 1);

  CORE_RETURN("properp", PROPER_LISTP(CAR(args)) ? TRUE : NIL);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _params
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_params(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("params");

  REQUIRE(env, args, (LENGTH(args) == 1) && (MACROP(CAR(args)) || LAMBDAP(CAR(args))));

  CORE_RETURN("params", FUN_PARAMS(CAR(args)));
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _body
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_body(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("body");

  REQUIRE(env, args, (LENGTH(args) == 1) && (MACROP(CAR(args)) || LAMBDAP(CAR(args))));

  CORE_RETURN("body", FUN_BODY(CAR(args)));
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _nl
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_nl(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("nl");

  int len = LENGTH(args);
  
  REQUIRE(env, args, len = 1, "nl takes no args");

  NL;
  
  CORE_RETURN("nl", NIL);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _env
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_env(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("env");

  int len = LENGTH(args);
  
  REQUIRE(env, args, len <= 1, "env requires 0 or 1 args");

  if (len == 1) {
    REQUIRE(env, args, (ENVP(CAR(args)) || LAMBDAP(CAR(args)) || MACROP(CAR(args))));
    
    CORE_RETURN("env", ENVP(CAR(args))
                ? ENV_PARENT(CAR(args))
                : FUN_ENV(CAR(args)));
  }
  
  CORE_RETURN("env", env);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _syms
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_syms(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("syms");

  REQUIRE(env, args, (LENGTH(args) == 1) && ENVP(CAR(args)));

  CORE_RETURN("syms", ENV_SYMS(CAR(args)));
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _errmsg
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_errmsg(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("errmsg");

  REQUIRE(env, args, (LENGTH(args) == 1) && ERRORP(CAR(args)));

  CORE_RETURN("errmsg", NEW_STRING(ERR_MSG(CAR(args))));
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _errobj
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_errobj(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("errobj");

  REQUIRE(env, args, (LENGTH(args) == 1) && ERRORP(CAR(args)));

  CORE_RETURN("errobj", ERR_OBJ(CAR(args)));
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _vals
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_vals(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("vals");

  REQUIRE(env, args, (LENGTH(args) == 1) && ENVP(CAR(args)));

  CORE_RETURN("vals", ENV_VALS(CAR(args)));
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _numer
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_numer(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("numer");

  REQUIRE(env, args, (LENGTH(args) == 1) && (RATIONALP(CAR(args)) || INTEGERP(CAR(args))));

  CORE_RETURN("numer", NEW_INT(NUMER_VAL(CAR(args))));
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _denom
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_denom(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("denom");

  REQUIRE(env, args, (LENGTH(args) == 1) && (RATIONALP(CAR(args)) || INTEGERP(CAR(args))));

  CORE_RETURN("denom", NEW_INT((RATIONALP(CAR(args)))
                               ? DENOM_VAL(CAR(args))
                               : 1));
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _type
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_type(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("type");

  REQUIRE(env, args, (LENGTH(args) == 1));

  const char * type = TYPE_STR(CAR(args));
  /* */ char * tmp  = free_list_malloc(strlen(type) + 2);

  sprintf(tmp, ":%s", type);

  ae_obj_t   * sym  = SYM(tmp);

  free_list_free(tmp);

  CORE_RETURN("type", sym);
}

/* //////////////////////////////////////////////////////////////////////////////////////////////////// */
/* // _quote */
/* //////////////////////////////////////////////////////////////////////////////////////////////////// */

/* ae_obj_t * ae_core_quote(ae_obj_t * const env, ae_obj_t * const args) { */
/*   CORE_BEGIN("quote"); */

/*   REQUIRE(env, args, LENGTH(args) == 1); */

/*   return CAR(args); */
/* } */

////////////////////////////////////////////////////////////////////////////////////////////////////
// _exit
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_exit(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("exit");
  
  REQUIRE(env, args, (LENGTH(args) == 1) && INTEGERP(CAR(args)));

  exit(INT_VAL(CAR(args)));

  return CAR(args);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _eval
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_eval(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("eval");
  
  REQUIRE(env, args, LENGTH(args) == 1);

  return EVAL(env, EVAL(env, CAR(args)));
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _lambda
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_lambda(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("lambda");
  
  REQUIRE(env, args, TAILP(CAR(args))
#ifndef AE_NO_SINGLE_SYM_PARAMS  
          || SYMBOLP(CAR(args))
#endif
          );
  REQUIRE(env, args, TAILP(CDR(args)));

  return NEW_LAMBDA(CAR(args), CDR(args), env);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _macro
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_macro(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("macro");

  REQUIRE(env, args, TAILP(CAR(args)));
  REQUIRE(env, args, TAILP(CDR(args)));

  return NEW_MACRO(CAR(args), CDR(args), env);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _cond
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_cond(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("cond");

  REQUIRE(env, args, "an empty cond does not make sense");

  ae_obj_t * caar = CAAR(args);
  ae_obj_t * cdar = CDAR(args);

  LOG(caar, "caar");
  LOG(cdar, "cdar");

  if (! NILP(EVAL(env, caar)))
    return EVAL(env, ae_core_progn(env, cdar));

  return ae_core_cond(env, CDR(args));
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _if
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_if(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("if");

#ifdef AE_CORE_BEGIN
  PR("if:          ");
  PRINC(CAR(args));
  NL;
  PR("then:        ");
  PRINC(CADR(args));
  NL;
  PR("else:        ");
  PRINC(CONS(SYM("progn"), CDDR(args)));
#endif

  REQUIRE(env, args, !NILP(CDR(args)), "if requires at least 2 args");
  
  bool cond_result = ! NILP(EVAL(env, CAR(args)));

#ifdef AE_CORE_BEGIN
  LOG(cond_result ? TRUE : NIL, "cond_result: ");
#endif

  if (cond_result) {
    PR("Choose then.\n");

    return EVAL(env, CADR(args));
  }
  else {
    PR("Choose else.\n");

    return EVAL(env, CONS(SYM("progn"), CDDR(args)));
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _msleep
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_msleep(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("msleep");

  REQUIRE(env, args, (LENGTH(args) == 1) && INTEGERP(CAR(args)));

  int ms = INT_VAL(CAR(args));

  usleep(ms * 1000);

  return CAR(args);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// _length
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_length(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("length");
  
  REQUIRE(env, args, (LENGTH(args) == 1) && TAILP(CAR(args)));

  int len = LENGTH(CAR(args));

  REQUIRE(env, args, len >= 0, "core length only works on proper lists");
          
  return NEW_INT(len);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _tailp
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_tailp(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("tailp");

  REQUIRE(env, args, (LENGTH(args) == 1) && TAILP(CAR(args)));

  return TAILP(CAR(args)) ? TRUE : NIL;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _car
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_car(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("car");

  REQUIRE(env, args, (LENGTH(args) == 1) && TAILP(CAR(args)));

  return NILP(CAR(args))
    ? NIL // car of nil is nil.
    : CAAR(args);
}


////////////////////////////////////////////////////////////////////////////////////////////////////
// _cdr
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_cdr(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("cdr");

  REQUIRE(env, args, (LENGTH(args) == 1) && TAILP(CAR(args)));

  return NILP(CAR(args))
    ? NIL // cdr of nil is nil.
    : CDAR(args);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _rplaca
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_rplaca(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("rplaca");

  REQUIRE(env, args, (LENGTH(args) <= 2) && CONSP(CAR(args)));

  CAAR(args) = CADR(args);
  
  return CADR(args);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _rplacd
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_rplacd(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("rplacd");

  REQUIRE(env, args, (LENGTH(args) <= 2) && CONSP(CAR(args)));

  CDAR(args) = CADR(args);
  
  return CADR(args);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _cons
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_cons(ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("cons");
  
  REQUIRE(env, args, LENGTH(args) >= 1);
  REQUIRE(env, args, LENGTH(args) <= 2);

  ae_obj_t * head = CAR(args);
  ae_obj_t * tail = CADR(args);

  return NEW_CONS(head, tail);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _eq
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_eq(__attribute__((unused)) ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("eq");

  FOR_EACH(tailarg, CDR(args))
    if (NEQ(CAR(args), tailarg))
      return NIL;

  return TRUE;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _eql
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_eql(__attribute__((unused)) ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("eql");

  FOR_EACH(tailarg, CDR(args))
    if (NEQL(CAR(args), tailarg))
      return NIL;

  return TRUE;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _not
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_not(__attribute__((unused)) ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("not");

  FOR_EACH(elem, args)
    if (! NILP(elem))
      return NIL;

  return TRUE;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _put
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_put(__attribute__((unused)) ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("put");

  int written = 0;

  FOR_EACH(elem, args)
    written += PUT(elem);

  fflush(stdout);

  return NEW_INT(written);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _princ
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_princ(__attribute__((unused)) ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("princ");

  int written = 0;

  FOR_EACH(elem, args)
    written += PRINC(elem);

  fflush(stdout);

  return NEW_INT(written);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _print
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_print(__attribute__((unused)) ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("print");

  int written = 0;

  FOR_EACH(elem, args) {
    written += PRINT(elem);

    if (! NILP(CDR(position))) {
      SPC;
      written++;
    }
  }

  fflush(stdout);

  return NEW_INT(written);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _write
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_write(__attribute__((unused)) ae_obj_t * const env, ae_obj_t * const args) {
  CORE_BEGIN("write");

  int written = 0;

  FOR_EACH(elem, args) {
    written += WRITE(elem);

    if (! NILP(CDR(position))) {
      SPC;
      written++;
    }
  }

  fflush(stdout);

  return NEW_INT(written);
}
