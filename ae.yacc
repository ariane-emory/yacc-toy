%{
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ae_obj.h"

#define YYSTYPE ae_obj_t

#define NL      putchar('\n')
#define BSPC    putchar('\b')
#define SPC     putchar(' ')
#define LPAR    putchar('(')
#define RPAR    putchar(')')
#define LSQR    putchar('[')
#define RSQR    putchar(']')
#define OBJ(x)  ae_obj_put(x)

  ae_obj_t * root    = 0;
  ae_obj_t * symbols = 0;
  
  void yyerror(const char *str) { fprintf(stderr, "Error: %s\n", str); }
  int yywrap() { return 1; }

  void describe(ae_obj_t * this) {
    static unsigned int indent = 0;
    
    for (int ct = 0; ct < indent << 1; ct++)
      SPC;
    
    OBJ(this);
    NL;
    
    if (this->type == AE_CONS____ && this->head) {
      ++indent;
      ae_obj_each(this, describe);
      --indent;
    }
  }

  void do_write(ae_obj_t * this) {
    ae_obj_write(this);
    NL;
  }

  extern FILE * yyin;

#ifdef POOL_SIZE
  extern ae_obj_t pool[POOL_SIZE];
#endif

  //////////////////////////////////////////////////////////////////////////////
  // main
  //////////////////////////////////////////////////////////////////////////////
  
  main() {
    symbols = NEW_AE_OBJ(AE_CONS____); // stop doing this!
    
    putchar('\n');

#define PRINT_SIZEOF(t)      printf("sizeof(" #t ") = %d bytes.\n", sizeof(t))
    PRINT_SIZEOF(int);
    PRINT_SIZEOF(ae_obj_t *);
    PRINT_SIZEOF(ae_obj_t);
    PRINT_SIZEOF(ae_type_t);
    printf("ae_obj data offset: %d\n", offsetof(ae_obj_t, str_value));

#ifdef POOL_SIZE
    printf("\nUsing pool from   %p to %p.\n\n", pool, &pool[POOL_SIZE]);
#endif
    
    FILE * fp = fopen("sample.txt", "r");
    yyin = fp;
    yyparse();

    printf("root:            ");
    ae_obj_put(root);
    NL;
    NL;
      
    ae_obj_t * program_obj = ALLOC_AE_OBJ; 
    ae_obj_unsafe_move(program_obj, root); // take the 'program' rule's ae_obj.

    NL;
    printf("program:         ");
    ae_obj_put(program_obj);
    NL;
    NL;
    puts("Describing items in program.");
    if (program_obj->type == AE_CONS____ && program_obj->head)
      ae_obj_each(program_obj, describe);
    puts("Described items in program.");
    NL;
    puts("Writing program obj.");
    ae_obj_write(program_obj);
    puts("\nWrote program obj.");
    NL;
    puts("Writing items in program obj.");
    if (program_obj->type == AE_CONS____ && program_obj->head)
      ae_obj_each(program_obj, do_write);
    puts("Wrote items in program obj.");
    NL;
    puts("Writing symbols in program.");
    ae_obj_write(symbols);
    puts("\nWrote symbols in program.");
    NL;

#define   PRINT_POOL

#ifdef    PRINT_POOL
    pool_print();
#endif // PRINT_POOL
  }

  //////////////////////////////////////////////////////////////////////////////
  // End of main
  //////////////////////////////////////////////////////////////////////////////
    
    %}

%token LPAREN RPAREN STRING INTEGER FLOAT RATIONAL MATHOP INCROP COMPARE SYMBOL QUOTE CHAR LIST INF
%start program

%%

program: sexps { root = &$$; }


atom: CHAR | COMPARE | FLOAT | INTEGER | MATHOP | RATIONAL | STRING | SYMBOL | INF;

list:
LPAREN sexps RPAREN { $$ = $2; };
| LIST {
  memset(&$$, 0, sizeof($$));
  
#ifdef NOISY_INIT
  printf("Initting $$ (a)  %p\n", &$$);
#endif  

  ae_obj_init(&$$, AE_CONS____);

#ifdef NOISY_INIT
  printf("Initted $$ (a)   %p\n\n", &$$);
#endif
}

sexp: list | atom

sexps:
sexps sexp {

  if (SYMBOLP(&$2)) {
    printf("Interning '%s'...\n", $2.sym_value);
    fflush(stdout);
    ae_obj_push_back(&$$, c_str_intern($2.sym_value, &symbols));
  }
  else {
    ae_obj_t * new_obj = ALLOC_AE_OBJ;
    ae_obj_unsafe_move(new_obj, &$2);
    ae_obj_push_back(&$$, new_obj);
  }
  
}
| {
  memset(&$$, 0, sizeof($$));

#ifdef NOISY_INIT  
  printf("Initting $$ (b)  %p\n", &$$);
#endif

  ae_obj_init(&$$, AE_CONS____);

#ifdef NOISY_INIT
  printf("Initted $$ (b)   %p\n\n", &$$);
#endif
};
   
%%
