#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ae_obj.h"
#include "ae_env.h"
#include "ae_eval.h"
#include "ae_free_list.h"
#include "ae_write.h"
#include "ae_util.h"

//////////////////////////////////////////////////////////////////////////////
// data
//////////////////////////////////////////////////////////////////////////////

#define free_list_size (1 << 16)
static char mem[free_list_size] = { 0 };

ae_obj_t * program = NIL;

//////////////////////////////////////////////////////////////////////////////
// extern decls
//////////////////////////////////////////////////////////////////////////////

extern int yyparse (void);
extern FILE * yyin;

//////////////////////////////////////////////////////////////////////////////
// describe
//////////////////////////////////////////////////////////////////////////////

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

//////////////////////////////////////////////////////////////////////////////
// do_write
//////////////////////////////////////////////////////////////////////////////

void do_write(ae_obj_t * this) {
  ae_write(this);
  NL;
}

//////////////////////////////////////////////////////////////////////////////
// preface
//////////////////////////////////////////////////////////////////////////////

void preface(void) {
  NL;
  printf("obj size:          %d.\n",    sizeof(ae_obj_t));
  printf("int size:          %d.\n",    sizeof(int));
  printf("nil is at:         %016p.\n", NIL);
  printf("t is at:           %016p.\n", TRUE);
  printf("Pool first:        %016p.\n", pool_first);
  printf("Pool last:         %016p.\n", pool_last);
  printf("Pool size:         %016p (%zu bytes).\n",
         sizeof(ae_obj_t) * AE_OBJ_POOL_SIZE,
         sizeof(ae_obj_t) * AE_OBJ_POOL_SIZE);
  printf("Strings pool size: %016p (%zu bytes).", free_list_size, free_list_size);
  NL;
}

//////////////////////////////////////////////////////////////////////////////
// main
//////////////////////////////////////////////////////////////////////////////

int main(void) {
  preface();
  
  free_list_add_block(&mem[0], free_list_size);
  
  PR("\nPopulating root env...");
  INDENT;
  ae_obj_t * env = ENV_NEW_ROOT();
  OUTDENT;
  LOG(env, "Done populating");
  
  
  FILE * fp = fopen("data/sample.lisp", "r");
  yyin = fp;
  yyparse();
  
// #ifdef AE_TRACK_ORIGINS_DURING_EVAL
  ae_obj_t * read_origin = NIL;
  ASET(read_origin, KW("origin"), KW("read"));
  
  int first_allocated;
  
  for (first_allocated = 0; first_allocated < AE_OBJ_POOL_SIZE; first_allocated++) 
    if (! FREEP(pool_get_object(first_allocated)))
      break;
  
  int ix = AE_OBJ_POOL_SIZE;
  
  while (ix --> first_allocated)
    if (! DHAS(pool_get_object(ix), "origin"))
      DOBJ(pool_get_object(ix)) = read_origin;
// #endif
  
#ifdef AE_DUMP_POOL_BEFORE
  pool_print();
#endif

  puts("Writing program obj.");
  WRITE(program);
  NL;
  puts("Wrote program obj.");
  NL;
  
  SLOG("Evaluating program...");
  EVAL(env, program);
  SLOG("\nDone evaluating program.\n");
  
#ifdef AE_DUMP_POOL_AFTER
  pool_print();
#endif
  
  fclose(fp);  
}

//////////////////////////////////////////////////////////////////////////////
// End of main
//////////////////////////////////////////////////////////////////////////////
