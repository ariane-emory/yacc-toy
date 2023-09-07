%{
#include <stdio.h>
#include <string.h>
#include "ae.h"

#define YACC_PRINT(x) { printf("Yac got %s.\n", ae_object_str(&x)); }

  void yyerror(const char *str) { fprintf(stderr, "Error: %s\n", str); }
  int yywrap() { return 1; }
  main() { yyparse(); }
    %}

%token LPAR RPAR STRING INTEGER FLOAT RATIONAL MATHOP INCROP COMPARE WORD QUOTE CHAR

%%
sexps: | sexps sexp { printf("Yac got sexps.\n"); };
sexp:
list                               { $$ = $1; printf("Yac got sexp (list).\n"); };
| atom                             { $$ = $1; printf("Yac got sexp (atom).\n"); };

atom:
string                             { $$ = $1; }
| integer                          { $$ = $1; }
| float                            { $$ = $1; }
| rational                         { $$ = $1; }
| mathop                           { $$ = $1; }
| compare                          { $$ = $1; }
| word                             { $$ = $1; }
| char                             { $$ = $1; };

list:     LPAR sexps RPAR          { $$ = $1; printf("Yac got list.\n"); };
string:   STRING                   { $$ = $1; YACC_PRINT($1); };
integer:  INTEGER                  { $$ = $1; YACC_PRINT($1); };
float:    FLOAT                    { $$ = $1; YACC_PRINT($1); };
rational: RATIONAL                 { $$ = $1; YACC_PRINT($1); };
mathop:   MATHOP                   { $$ = $1; YACC_PRINT($1); };
compare:  COMPARE                  { $$ = $1; YACC_PRINT($1); };
word:     WORD                     { $$ = $1; YACC_PRINT($1); };
char:     CHAR                     { $$ = $1; YACC_PRINT($1); };

%%
