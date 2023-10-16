#pragma once

#include <stdbool.h>

#include "obj.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
#define EVAL(env, obj)        (ae_eval((env), (obj)))
#define EVAL_ARGS(env, obj)   (ae_eval_args((env), (obj)))
////////////////////////////////////////////////////////////////////////////////////////////////////
extern bool log_eval;
////////////////////////////////////////////////////////////////////////////////////////////////////
ae_obj_t * ae_eval (ae_obj_t * env, ae_obj_t * obj);
////////////////////////////////////////////////////////////////////////////////////////////////////
ae_obj_t * ae_eval_args(ae_obj_t  * const env, ae_obj_t * const args);
