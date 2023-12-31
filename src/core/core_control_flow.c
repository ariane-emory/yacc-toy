#include "core_includes.h"

#include "jump_return.h"
#include "common.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
// _progn
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_progn(ae_obj_t * const env, ae_obj_t * const args, __attribute__((unused)) int args_length) {
  CORE_BEGIN("progn");

  int ctr = 0;
  
  FOR_EACH(elem, args) {
    ctr++;

    if (log_core)
      LOG(elem, "eval progn arg  #%d/%d", ctr, args_length);

    ret = RETURN_IF_ERRORP(EVAL(env, elem));
        
    if (log_core)
      LOG(ret, "progn arg #%d/%d evaluated to", ctr, args_length);
  }

end:
  
  CORE_RETURN("progn", ret);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _case
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_case(ae_obj_t * const env, ae_obj_t * const args, __attribute__((unused)) int args_length) {
  CORE_BEGIN("case");

  ae_obj_t * const key_form   = RETURN_IF_ERRORP(EVAL(env, CAR(args)));
  ae_obj_t * const case_forms = CDR(args);

  REQUIRE(env, args, ! NILP(case_forms), "case requires at least one form after the key form");

  if (log_core) {
    LOG(key_form,   "key_form");
    LOG(case_forms, "case_forms");
  }

  bool else_found = false;

  // First pass: Check for well-formedness and multiple else clauses
  FOR_EACH(case_form, case_forms) {
    REQUIRE(env, args, PROPERP(case_form) && LENGTH(case_form) > 1, "case forms must be proper lists with at least two elements");

    ae_obj_t * const case_form_car = CAR(case_form);

    if (case_form_car == SYM("else")) {
      REQUIRE(env, args, !else_found, "Only one else clause is allowed in a case expression");
      else_found = true;
    }
  }

  // Second pass: Evaluate which case matches
  ae_obj_t * selected_value_form = NIL;

  FOR_EACH(case_form, case_forms) {
    ae_obj_t * const case_form_car = CAR(case_form);
    ae_obj_t * const case_form_cdr = CDR(case_form);

    if (log_core) {
      LOG(case_form_car, "case_form's car");
      LOG(case_form_cdr, "case_form's cdr");
    }

    if (case_form_car == SYM("else")) {
      selected_value_form = case_form_cdr;
    } else {
      INDENT;

      ae_obj_t * elements_to_check = CONSP(case_form_car) ? case_form_car : CONS(case_form_car, NIL);  // Single values wrapped in a list

      FOR_EACH(case_form_car_elem, elements_to_check) {
        if (log_core)
          LOG(case_form_car_elem, "case_form_car_elem");

        if (EQL(key_form, case_form_car_elem)) {
          if (log_core)
            SLOG("matches");
          CORE_RETURN("case", RETURN_IF_ERRORP(ae_core_progn(env, case_form_cdr, LENGTH(case_form_cdr))));
        } else if (log_core) {
          SLOG("doesn't match");
        }
      }

      OUTDENT;
    }
  }

  if (selected_value_form) {  // If there's an else clause and no prior match was found
    CORE_RETURN("case", RETURN_IF_ERRORP(ae_core_progn(env, selected_value_form, LENGTH(selected_value_form))));
  }

end:
  CORE_RETURN("case", NIL);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _cond
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_cond(ae_obj_t * const env, ae_obj_t * const args, __attribute__((unused)) int args_length) {
  CORE_BEGIN("cond");

  bool else_found = false;
    
  // First pass: Ensure no duplicate 'else' clauses and validate structure
  FOR_EACH(cond_item, args) {
    REQUIRE(env, args, PROPERP(cond_item) && LENGTH(cond_item) > 1, "cond arguments must be proper lists with at least two elements");

    ae_obj_t * const item_car = CAR(cond_item);

    if (item_car == SYM("else")) {
      REQUIRE(env, args, !else_found, "Only one else clause is allowed in a cond expression");
      else_found = true;
      REQUIRE(env, args, NILP(CDR(position)), "If used, else clause must be the last clause in a cond expression");
    }
  }

  // Second pass: Evaluate the conditions
  FOR_EACH(cond_item, args) {
    ae_obj_t * const item_car = CAR(cond_item);
    ae_obj_t * const item_cdr = CDR(cond_item);

    ae_obj_t * cond_test_result = NIL;

    if (item_car == SYM("else")) {
      cond_test_result = TRUE;
    } else {
      cond_test_result = RETURN_IF_ERRORP(EVAL(env, item_car));
    }

    if (! NILP(cond_test_result)) {
      ret = RETURN_IF_ERRORP(ae_core_progn(env, item_cdr, LENGTH(item_cdr)));
      break;
    }
  }

end:
  CORE_RETURN("cond", ret);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _if
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_if(ae_obj_t * const env, ae_obj_t * const args, __attribute__((unused)) int args_length) {
  CORE_BEGIN("if");

  ae_obj_t * const if_cond     = CAR(args);
  ae_obj_t * const then_branch = CADR(args);
  ae_obj_t * const else_branch = CDDR(args);
  
  if (log_core) {
    LOG(if_cond,     "if");
    LOG(then_branch, "then");
    LOG(else_branch, "else");
  }

  bool cond_result = ! NILP(RETURN_IF_ERRORP(EVAL(env, if_cond)));

  if (log_core) 
    LOG(cond_result ? TRUE : NIL, "cond_result: ");

  if (cond_result) {
    if (log_core)
      LOG(then_branch, "chose then");

    ret = RETURN_IF_ERRORP(EVAL(env, then_branch));
  } 
  else {
    if (log_core)
      LOG(else_branch, "chose else");

    ret = RETURN_IF_ERRORP(ae_core_progn(env, else_branch, LENGTH(else_branch)));
  }

end:
  
  CORE_RETURN("if", ret);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _when
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_when(ae_obj_t * const env, ae_obj_t * const args, __attribute__((unused)) int args_length) {
  CORE_BEGIN("when");

  ae_obj_t * const when_cond   = CAR(args);
  ae_obj_t * const then_branch = CDR(args);
  
  if (log_core) {
    LOG(when_cond,   "when");
    LOG(then_branch, "then");
  }

  bool cond_result = ! NILP(RETURN_IF_ERRORP(EVAL(env, when_cond)));

  if (log_core)
    LOG(cond_result ? TRUE : NIL, "cond_result: ");

  if (cond_result) {
    if (log_core)
      LOG(then_branch, "chose then");

    ret = RETURN_IF_ERRORP(ae_core_progn(env, then_branch, LENGTH(then_branch)));
  }

  if (log_core)
    SLOG("chose nil");

end:
  
  CORE_RETURN("when", ret);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _unless
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_unless(ae_obj_t * const env, ae_obj_t * const args, __attribute__((unused)) int args_length) {
  CORE_BEGIN("unless");

  ae_obj_t * const unless_cond = CAR(args);
  ae_obj_t * const then_branch = CDR(args);
  
  if (log_core) {
    LOG(unless_cond, "unless");
    LOG(then_branch, "then");
  }

  bool cond_result = NILP(RETURN_IF_ERRORP(EVAL(env, unless_cond)));

  if (log_core)
    LOG(cond_result ? TRUE : NIL, "cond_result: ");

  if (cond_result) {
    if (log_core)
      LOG(then_branch, "chose then");

    ret = RETURN_IF_ERRORP(ae_core_progn(env, then_branch, LENGTH(then_branch)));
  }

  if (log_core)
    SLOG("chose nil");

end:
  
  CORE_RETURN("unless", ret);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _or
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_or(ae_obj_t * const env, ae_obj_t * const args, __attribute__((unused)) int args_length) {
  CORE_BEGIN("or");

  
  FOR_EACH(option, args) {
    ret = RETURN_IF_ERRORP(EVAL(env, option));

    if (log_core)
      LOG(ret, "or option");
    
    if (! NILP(ret))
      break;
  }
      
end:
    
  CORE_RETURN("or", ret);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _and
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_and(ae_obj_t * const env, ae_obj_t * const args, __attribute__((unused)) int args_length) {
  CORE_BEGIN("and");

  FOR_EACH(option, args) {
    ret = RETURN_IF_ERRORP(EVAL(env, option));

    if (log_core)
      LOG(ret, "and option");

    if (NILP(ret))
      break;
  }

end:  
  CORE_RETURN("and", ret);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _while
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_while(ae_obj_t * const env, ae_obj_t * const args, __attribute__((unused)) int args_length) {
  CORE_BEGIN("while");

  ae_obj_t * const while_cond = CAR(args);
  ae_obj_t * const do_branch  = CDR(args);
  
  if (log_core) {
    LOG(while_cond, "while");
    LOG(do_branch,  "do");
  }
  
  while (! NILP(RETURN_IF_ERRORP(EVAL(env, while_cond)))) {
    if (log_core)
      LOG(do_branch, "do while");

    ret = RETURN_IF_ERRORP(ae_core_progn(env, do_branch, LENGTH(do_branch)));
  }

end:
  
  if (log_core)
    SLOG("left while");
  
  CORE_RETURN("while", ret);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _until
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_until(ae_obj_t * const env, ae_obj_t * const args, __attribute__((unused)) int args_length) {
  CORE_BEGIN("until");

  ae_obj_t * const until_cond = CAR(args);
  ae_obj_t * const do_branch  = CDR(args);
  
  if (log_core) {
    LOG(until_cond, "until");
    LOG(do_branch,  "do");
  }
  
  // ae_obj_t * cond_result = NIL;

  while (NILP(RETURN_IF_ERRORP(EVAL(env, until_cond)))) {
    if (log_core)
      LOG(do_branch, "do until");

    ret = RETURN_IF_ERRORP(ae_core_progn(env, do_branch, LENGTH(do_branch)));
  }

end:
  
  if (log_core)
    SLOG("left until");
  
  CORE_RETURN("until", ret);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// _repeat
////////////////////////////////////////////////////////////////////////////////////////////////////

ae_obj_t * ae_core_repeat(ae_obj_t * const env, ae_obj_t * const args, __attribute__((unused)) int args_length) {
  CORE_BEGIN("repeat");

  ae_obj_t * first_arg = RETURN_IF_ERRORP(EVAL(env, CAR(args)));
 
  REQUIRE(env, args, INTEGERP(first_arg), "repeat requires an integer as its first argument");

  long long int times = INT_VAL(first_arg);

  for (long long int ix = 0; ix < times; ix++)
    ret = RETURN_IF_ERRORP(ae_core_progn(env, CDR(args), LENGTH(CDR(args))));

end:
  
  CORE_RETURN("repeat", ret);
}

