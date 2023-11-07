#pragma once

#include "obj.h"

#define free_list_size (1 << 18)

////////////////////////////////////////////////////////////////////////////////////////////////////
// types
////////////////////////////////////////////////////////////////////////////////////////////////////
typedef enum {
  NO_STD               = 1,
  STD_FUNDAMENTAL      = 2,
  STD_MONO             = 4, 
  LOG_EVAL             = 8,  
  LOG_CORE             = 16, 
  LOG_MACRO            = 32, 
  EARLY_LOGGING        = 64, 
  OPTS_OK              = 128,
  MICROBENCH_ENABLED   = 256,
} setopts_flag_t;
////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////
// data
////////////////////////////////////////////////////////////////////////////////////////////////////
extern char       string_pool[free_list_size]; // the string pool.
extern ae_obj_t * program;                     // bison will put the last parsed program here.
extern bool       log_core;                    // global toggle.
extern bool       log_eval;                    // global toggle.
extern bool       log_macro;                   // global toggle.
extern bool       read_error;                  // set by yacc/flex, read by repl.c/ae.c.
extern ae_obj_t * filename_stack;              // keeps track of the current file being parsed.
extern ae_obj_t * line_stack;                  // keeps track of line in previous file.
////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////
// functions
////////////////////////////////////////////////////////////////////////////////////////////////////
void            preface(void); 
void            paint_parsed(void);
int             setopts(int argc, char * argv[]);
ae_obj_t *      load_file(const char * filename, bool * const failed_to_open);
////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////
#define    NEW_ROOT(log_loading_std, flags) ae_common_new_root((log_loading_std), (flags))
////////////////////////////////////////////////////////////////////////////////////////////////////
