#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "common.h"
#include "core.h"
#include "env.h"
#include "eval.h"
#include "free_list.h"
#include "log.h"
#include "obj.h"
#include "write.h"

extern bool read_error;

////////////////////////////////////////////////////////////////////////////////////////////////////  
// describe
////////////////////////////////////////////////////////////////////////////////////////////////////  

void describe(ae_obj_t * this, bool dotted) {
  static unsigned int indent = 0;

  char buff[128] = { 0 };
  
  int written = 0;

  while (written++ < ((int)(indent - (dotted ? 2 : 0)))) SPC;

  if (dotted)
    written += PR("• "); 
  
  written += PR("%018p", this);
  
  while (written++ < 32) SPC;

// This hacky extra print is required because we printed a multi-byte character earlier:
  if (dotted)
    written += PR("  ");
  
  written += PUT(this);
  
  while (written++ < 105) SPC;

// PUT_words(this);

  NL;
  
  if (CONSP(this)) {
    indent += 2;
    FOR_EACH(elem, this) {
      describe(elem, false);
      if (! TAILP(CDR(position)))
        describe(CDR(position), true);
    }
    indent -= 2;
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////  
// do_write
////////////////////////////////////////////////////////////////////////////////////////////////////  

void do_write(ae_obj_t * this) {
  ae_write(this);
  NL;
}

////////////////////////////////////////////////////////////////////////////////////////////////////  
// main
////////////////////////////////////////////////////////////////////////////////////////////////////  

int main(int argc, char **argv) {

////////////////////////////////////////////////////////////////////////////////////////////////////
// setops
////////////////////////////////////////////////////////////////////////////////////////////////////

  setopts_result_t setopts_result = { 0 };

  setopts(argc, argv, &setopts_result);
  
  if (! setopts_result.opts_ok) {
    FPR(stderr, "ERROR: Bad opts!\n");
    exit(1);
  }

  log_eval  = setopts_result.log_eval;
  log_core  = setopts_result.log_core;
  log_macro = setopts_result.log_macro;

////////////////////////////////////////////////////////////////////////////////////////////////////
// setup root env
////////////////////////////////////////////////////////////////////////////////////////////////////
  
  ae_obj_t * const root_env = ENV_NEW_ROOT(true, true, setopts_result.std_mode);
  
////////////////////////////////////////////////////////////////////////////////////////////////////
// read and parse file
////////////////////////////////////////////////////////////////////////////////////////////////////

  bool failed_to_open = false;

  load_file("data/tests.lisp", &failed_to_open);

  if (failed_to_open) {
    FPR(stderr, "ERROR: Failed to open file!\n");
    exit(1);
  }

  if (read_error) {
    FPR(stderr, "ERROR: Read error!\n");
    exit(2);
  }

  paint_parsed();
  
////////////////////////////////////////////////////////////////////////////////////////////////////
// dump the pool, eval the program, dump the pool again
////////////////////////////////////////////////////////////////////////////////////////////////////  

#ifdef AE_DUMP_POOL_BEFORE
  pool_print();
#endif

  /* puts("Writing program obj."); */
  /* WRITE(program); */
  /* NL; */
  /* puts("Wrote program obj."); */
  /* NL; */
  
  /* SLOG("Evaluating program..."); */
  
  ae_obj_t * result = EVAL(root_env, program);

  if (ERRORP(result)) {
    PR("\nERROR: "); WRITE(result); NL;

    exit(4);
  }
  /* else { */
  /*   PR("Result: "); WRITE(result); NL; */
  /* } */
  
  /* SLOG("\nDone evaluating program.\n"); */
  
#ifdef AE_DUMP_POOL_AFTER
  pool_print();
#endif

#ifdef AE_DUMP_SYMS
  PR("syms: "); WRITE(ENV_SYMS(root_env)); NL;
#endif

#ifdef AE_DUMP_VALS
  PR("vals: "); WRITE(ENV_VALS(root_env)); NL;
#endif
}

////////////////////////////////////////////////////////////////////////////////////////////////////  
// End of main
////////////////////////////////////////////////////////////////////////////////////////////////////  
