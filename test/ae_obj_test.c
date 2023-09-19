#include <assert.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BEFORE_ACUTEST

#include "ae_obj.h"

#include "acutest.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
// Macros
////////////////////////////////////////////////////////////////////////////////////////////////////

#define T  TEST_CHECK
#define TM TEST_MSG

#define NL putchar('\n');
#define FF fflush(stdout);

#define COUNT_LIST_LENGTH(l) list_length_counter = 0; EACH((l), incr_list_length_counter);

static char * tmp_str = NULL;

#define SETUP_TEST                                                                                 \
  ae_obj_t *    this    = NULL;                                                                    \
  ae_obj_t *    that    = NULL;                                                                    \
  pool_clear();                                                                                    \
  if (tmp_str) {                                                                                   \
    free(tmp_str);                                                                                 \
    tmp_str = NULL;                                                                                \
  }                                                                                                \
  (void)this;                                                                                      \
  (void)that;

////////////////////////////////////////////////////////////////////////////////////////////////////
// Helpers
////////////////////////////////////////////////////////////////////////////////////////////////////

void before_acutest() {
  printf("Test with " NIL_DESCRIPTION "\n");
}

char * write_to_new_string(const ae_obj_t * const this) {
  char * buff;
  size_t size;
  FILE * stream = open_memstream(&buff, &size);

  ae_obj_fwrite(this, stream);
  fclose(stream);

  return buff;
}

bool shitty_write_based_equality_predicate(
  const ae_obj_t * const this,
  const char * const strcmp_str
) {
  return ! strcmp(strcmp_str, SWRITE(this));
}

ae_obj_t * push_together_a_list_of_ints(void) {
  ae_obj_t * list    = NEW(AE_CONS);
  ae_obj_t * tailtip = list;

  T(LENGTH(tailtip) == 0);

  for (int ix = 0; ix < 4; ix++) { 
    ae_obj_t * new_int = NEW(AE_INTEGER);
    int        int_val = ix + 1;
    new_int->int_val   = int_val;

    tailtip              = PUSH(tailtip, new_int);
    
    T(CONSP(tailtip));
    T(INTEGERP(CAR(tailtip)));
    T(INT_VAL(CAR(tailtip)) == int_val);
    T(LENGTH(list) == ix + 1);
    TM("Length is %zu.", LENGTH(tailtip));
  }

  return list;
}

void mini_test(void)
{
  SETUP_TEST;

  putchar('\n');

  printf("NIL  is at %p.\n", NIL);
  FF;
  
  ae_obj_t * num = NEW(AE_INTEGER);
  INT_VAL(num)  = 12;
  printf("num  is at %p [ %d ].\n", num, INT_VAL(num));
  FF;
  
  this = CONS(num, NIL);
  printf("this is at %p [ %p %p ].\n", this, CAR(this), CDR(this));
  FF;

  num           = NEW(AE_INTEGER);
  INT_VAL(num)  = 13;
  printf("num  is at %p [ %d ].\n", num, INT_VAL(num));
  FF;

///  PUSH(this, num);
  
  /* this = CONS(num, this); */
  /* printf("this is at %p [ %p %p ].\n", this, CAR(this), CDR(this)); */
  /* FF; */
  
  /* num           = NEW(AE_INTEGER); */
  /* INT_VAL(num)  = 14; */
  /* printf("num  is at %p [ %d ].\n", num, INT_VAL(num)); */
  /* FF; */
  
  /* this = CONS(num, this); */
  /* printf("this is at %p [ %p %p ].\n", this, CAR(this), CDR(this)); */
  /* FF; */

  pool_print();

  WRITE(this);
  putchar('\n');
  
  return;
  
  putchar('\n');
  PUT(this);
  putchar('\n');
  
}

ae_obj_t * cons_together_a_list_of_ints(void) {

  ae_obj_t * head = NEW(AE_INTEGER);
  head->int_val   = 4;

  ae_obj_t * list = CONS(head, NIL);
  
  T(LENGTH(list) == 1);

  for (unsigned int ix = 0; ix < 3; ix++) { 
    ae_obj_t * new_head = NEW(AE_INTEGER);
    new_head->int_val = 3 - ix;

    ae_obj_t * tail = list;
    
    list = CONS(new_head, tail);

    const int expected_length = 2 + ix;
  
    T(list != head);
    T(list != new_head);
    T(CAR(list) == new_head);
    T(CDR(list) == tail);
    T(LENGTH(list) == expected_length);
    TEST_MSG(
      "Incorrect length %d, expected %d.",
      LENGTH(list),
      expected_length);
  }
  
  return list;
}

static int list_length_counter = 0;

void incr_list_length_counter(ae_obj_t * const this) {
  (void)this;
  list_length_counter++;
}

ae_obj_t * ae_obj_double(ae_obj_t * const this) {
  ASSERT_INTEGERP(this);

  ae_obj_t * new_obj = NEW(AE_INTEGER);
  new_obj->int_val = this->int_val * 2;

  return new_obj;
}

ae_obj_t * ae_obj_to_pairs(ae_obj_t * const this) {
  ae_obj_t * new_list = NEW(AE_CONS);
  
  CAR(new_list) = (ae_obj_t *)this;

  return CONS((ae_obj_t *)this, new_list);
}

void basic_list_checks(ae_obj_t * this) {
  pool_print();

  putchar('\n');

  printf("NIL  is at %p.\n", NIL);
  FF;

  COUNT_LIST_LENGTH(this);

  T(LENGTH(this) == 4);
  T(list_length_counter == 4);
  T(list_length_counter == LENGTH(this));

  WRITE(this); NL;
  
  T(shitty_write_based_equality_predicate(this, "(1 2 3 4)"));
  tmp_str = SWRITE(this); TM("Got \"%s\".", tmp_str);

  ae_obj_t * mapped = MAP(this, ae_obj_double);
  
  T(shitty_write_based_equality_predicate(mapped, "(2 4 6 8)"));

  tmp_str = SWRITE(this); TM("Got \"%s\".", tmp_str);

  /* T(shitty_write_based_equality_predicate(CLONE(MAP(this, ae_obj_double)), "(2 4 6 8)")); */
  /* tmp_str = SWRITE(this); TM("Got \"%s\".", tmp_str); */

  /* T(shitty_write_based_equality_predicate(CLONE(MAP(this, ae_obj_to_pairs)), "((1 1) (2 2) (3 3) (4 4))")); */
  /* tmp_str = SWRITE(this); TM("Got \"%s\".", tmp_str); */
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Tests
////////////////////////////////////////////////////////////////////////////////////////////////////

void remove_interned_elem_from_list(void) {
  SETUP_TEST;
 
  this = NEW(AE_CONS);

#define TEST_INTERN(str)                                                                           \
  {                                                                                                \
    int len = LENGTH(this);                                                                        \
    T(EQ(INTERN(&this, str), INTERN(&this, str)));                                                 \
    T(LENGTH(this) == (len + 1));                                                                  \
  }
    
  // using 'this' as the symbol list here:  
  T(EQ(INTERN(&this, "a"), INTERN(&this, "a")));
  T(LENGTH(this) == 1);
  T(EQ(INTERN(&this, "b"), INTERN(&this, "b")));
  T(LENGTH(this) == 2);
  T(EQ(INTERN(&this, "c"), INTERN(&this, "c")));
  T(LENGTH(this) == 3);
  T(EQ(INTERN(&this, "d"), INTERN(&this, "d")));
  T(LENGTH(this) == 4);

  that = INTERN(&this, "b");

  // Add a duplicate element so that we can see that both instances are removed:
  this = CONS(that, this);
  
  T(LENGTH(this) == 5);
  T(MEMBER(this, that));
  
  this = REMOVE(this, that);
  
  T(LENGTH(this) == 3);
  T(! MEMBER(this, that));
  T(shitty_write_based_equality_predicate(this, "(d c a)"));
}

void test_setup_is_okay(void)
{
  SETUP_TEST;
}

void newly_allocated_ae_obj_is_inside_pool(void)
{
  SETUP_TEST;
  this = ALLOC();
  T(this >= pool_first && this <= pool_last);
  TEST_MSG("obj @ %p is outside of pool (pool begins at %p, ends at %p).", this, pool_first, pool_last);
}

void newly_allocated_ae_obj_type_is_AE_INVALID(void)
{
  SETUP_TEST;
  T(INVALIDP(ALLOC()));
}

void newly_initialized_ae_obj_has_correct_type_field(void) {
#define test(_type)                                                                                \
  {                                                                                                \
    SETUP_TEST;                                                                                    \
    this = NEW(_type);                                                                             \
    T(TYPE(this) == _type);                                                                        \
  }
  FOR_EACH_LEXED_TYPE(test);
}

void newly_initialized_ae_obj_has_zeroed_data_fields(void) {
  SETUP_TEST;
  this = NEW(AE_RATIONAL);
  T(this->numerator_val == 0 && this->denominator_val == 0);
}

void consed_list_tests(void) {
  SETUP_TEST;
  basic_list_checks(cons_together_a_list_of_ints());
}

void pushed_list_tests(void) {
  SETUP_TEST;
  basic_list_checks(push_together_a_list_of_ints());
}

void unsafe_move_an_ae_obj(void) {
  SETUP_TEST;

  that = NEW(AE_RATIONAL);
  that->numerator_val   = 123;
  that->denominator_val = 321;

  this = MOVE_NEW(that);

  T(RATIONALP(this));
  T(this->numerator_val   == 123);
  T(this->denominator_val == 321);

  T(FREEP(that));
  T(that->numerator_val   == 0);
  T(that->denominator_val == 0);
}

void clone_a_simple_ae_obj(void) {
  SETUP_TEST;

  this = NEW(AE_RATIONAL);
  this->numerator_val   = 123;
  this->denominator_val = 321;

  that = CLONE(this);

  T(this != that);
  T(RATIONALP(that));
  T(that->numerator_val   == 123);
  T(that->denominator_val == 321);
}

void pushed_and_consed_lists_write_identically(void) {
  SETUP_TEST;
  this    = push_together_a_list_of_ints();
  tmp_str = SWRITE(this);
  T(shitty_write_based_equality_predicate(cons_together_a_list_of_ints(), tmp_str));
}

void intern_symbols(void) {
  SETUP_TEST;

  // deliberately avoid initializing this because INTERN should do so itself automatically.
  
  // re-use 'this' as the symbol list here:
  T(INTERN(&this, "one") == INTERN(&this, "one"));
  T(LENGTH(this) == 1);
  T(INTERN(&this, "one") != INTERN(&this, "two"));
  T(LENGTH(this) == 2);
}

#define FWRITE_TEST(type, field, val, ...)                                                         \
  {                                                                                                \
    this        = NEW(type);                                                                       \
    this->field = val;                                                                             \
                                                                                                   \
    __VA_ARGS__;                                                                                   \
                                                                                                   \
    char * buff;                                                                                   \
    size_t size;                                                                                   \
    FILE * stream   = open_memstream(&buff, &size);                                                \
    int    reported = ae_obj_fwrite(this, stream);                                                 \
                                                                                                   \
    fclose(stream);                                                                                \
    free(buff);                                                                                    \
                                                                                                   \
    T((int)strlen(buff) == (int)size);                                                             \
    TM("strlen was %d but size was %d:\n\"%s\".\n",                                                \
       (int)strlen(buff), (int)size, buff);                                                        \
    T((int)strlen(buff) == (int)reported);                                                         \
    TM("strlen was %d but reported was %d:\n\"%s\".\n",                                            \
       (int)strlen(buff), (int)reported, buff);                                                    \
  }

void fwrite_lengths(void) {
  SETUP_TEST;

  FWRITE_TEST(AE_CHAR,     int_val,       '1'                                 );
  FWRITE_TEST(AE_CHAR,     int_val,       '\n'                                );
  FWRITE_TEST(AE_INTEGER,  int_val,       123                                 );
  FWRITE_TEST(AE_FLOAT,    float_val,     1.23                                );
  FWRITE_TEST(AE_RATIONAL, numerator_val, 123,   this->denominator_val = 456; );
  FWRITE_TEST(AE_STRING,   str_val,       "asdf"                              );
  FWRITE_TEST(AE_SYMBOL,   sym_val,       "ghij"                              );
}

void truth(void) {
  SETUP_TEST;

  this = ae_obj_truth(true);

  T(SYMBOLP(this) && strcmp(SYM_VAL(this), "t") == 0);
  
  that = ae_obj_truth(false);

  T(NILP(that));
}

void equal(void) {
  SETUP_TEST;

  ae_obj_t * obj_int_2a      = NEW(AE_INTEGER);
  INT_VAL   (obj_int_2a)     = 2;

  ae_obj_t * obj_int_2b      = NEW(AE_INTEGER);
  INT_VAL   (obj_int_2b)     = 2;

  ae_obj_t * obj_float_2a    = NEW(AE_FLOAT);
  FLOAT_VAL (obj_float_2a)   = 2.0;

  ae_obj_t * obj_float_2b    = NEW(AE_FLOAT);
  FLOAT_VAL (obj_float_2b)   = 2.0;

  ae_obj_t * obj_int_3a      = NEW(AE_INTEGER);
  INT_VAL   (obj_int_3a)     = 3;

  ae_obj_t * obj_int_3b      = NEW(AE_INTEGER);
  INT_VAL   (obj_int_3b)     = 3;

  ae_obj_t * obj_float_3a    = NEW(AE_FLOAT);
  FLOAT_VAL (obj_float_3a)   = 3.0;

  ae_obj_t * obj_float_3b    = NEW(AE_FLOAT);
  FLOAT_VAL (obj_float_3b)   = 3.0;

  ae_obj_t * obj_bool_false  = ae_obj_truth(false);
  ae_obj_t * obj_bool_true   = ae_obj_truth(obj_float_2a);

  ae_obj_t * obj_list_consed = cons_together_a_list_of_ints();
  ae_obj_t * obj_list_pushed = push_together_a_list_of_ints();

  ae_obj_t * obj_rat_2a      = NEW(AE_RATIONAL);
  NUMER_VAL (obj_rat_2a)     = 2;
  DENOM_VAL (obj_rat_2a)     = 1;
  
  ae_obj_t * obj_rat_2b      = NEW(AE_RATIONAL);
  NUMER_VAL (obj_rat_2b)     = 4;
  DENOM_VAL (obj_rat_2b)     = 2;
  
  ae_obj_t * obj_rat_3a      = NEW(AE_RATIONAL);
  NUMER_VAL (obj_rat_3a)     = 3;
  DENOM_VAL (obj_rat_3a)     = 1;
  
  ae_obj_t * obj_rat_3b      = NEW(AE_RATIONAL);
  NUMER_VAL (obj_rat_3b)     = 9;
  DENOM_VAL (obj_rat_3b)     = 3;
  
#define FOR_EVERY_OBJ_DO(X)                                                                        \
  X(  obj_int_2a)                                                                                  \
    X(obj_int_2b)                                                                                  \
    X(obj_float_2a)                                                                                \
    X(obj_float_2b)                                                                                \
    X(obj_int_3a)                                                                                  \
    X(obj_int_3b)                                                                                  \
    X(obj_float_3a)                                                                                \
    X(obj_float_3b)                                                                                \
    X(obj_bool_false)                                                                              \
    X(obj_bool_true)                                                                               \
    X(obj_list_consed)                                                                             \
    X(obj_list_pushed)                                                                             \
    X(obj_rat_2a)                                                                                  \
    X(obj_rat_2b)                                                                                  \
    X(obj_rat_3a)                                                                                  \
    X(obj_rat_3b)

#define NETP(first, second)                                                                        \
  if (first != second) {                                                                           \
    T( NEQL( (first)  , (second) ));                                                               \
    T( NEQL( (second) , (first)  ));                                                               \
  }

#define ETP(first, second)                                                                         \
  T( EQL( (first)  , (second) ));                                                                  \
  T( EQL( (second) , (first)  ));

#define SELF_EQUAL(o)                                                                              \
  ETP( obj_bool_false , obj_bool_false );

  //  Everything is equal to itself.
  FOR_EVERY_OBJ_DO(SELF_EQUAL);
  
  //  Some numbers are equal to each other:
  ETP( obj_int_2a    , obj_int_2b   );
  ETP( obj_float_2a  , obj_float_2b );
  ETP( obj_rat_2a    , obj_rat_2b   );
  ETP( obj_int_3a    , obj_int_3b   );
  ETP( obj_float_3a  , obj_float_3b );
  ETP( obj_rat_3a    , obj_rat_3b   );
  // ... even if the y have different types:
  ETP( obj_int_2a    , obj_float_2a );
  ETP( obj_int_2a    , obj_rat_2b   );
  ETP( obj_rat_2a    , obj_float_2a );
  ETP( obj_int_3a    , obj_float_3a );
  ETP( obj_int_3a    , obj_rat_3b   );
  ETP( obj_rat_3a    , obj_float_3a );

  //  Some numbers are not equal to each other.
  NETP( obj_int_2a   , obj_int_3a   );
  NETP( obj_int_2a   , obj_float_3a );
  NETP( obj_int_2a   , obj_int_3a   );
  NETP( obj_int_2a   , obj_rat_3a   );

  NETP( obj_float_2a , obj_int_3a   );
  NETP( obj_float_2a , obj_float_3a );
  NETP( obj_float_2a , obj_int_3a   );
  NETP( obj_float_2a , obj_rat_3a   );

  NETP( obj_rat_2a   , obj_int_3a   );
  NETP( obj_rat_2a   , obj_float_3a );
  NETP( obj_rat_2a   , obj_int_3a   );
  NETP( obj_rat_2a   , obj_rat_3a   );

  // These aren't equal to anything other than themselves:
#define XX(other) NETP(obj_bool_false, other);
  FOR_EVERY_OBJ_DO(XX);
#undef XX

#define XX(other) NETP(obj_bool_true, other);
  FOR_EVERY_OBJ_DO(XX);
#undef XX

#define XX(other) NETP(obj_list_consed, other);
  FOR_EVERY_OBJ_DO(XX);
#undef XX
                                                         
#define XX(other) NETP(obj_list_pushed, other);
  FOR_EVERY_OBJ_DO(XX);
#undef XX

    /* todo: add tests for rationals */
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// TEST_LIST
////////////////////////////////////////////////////////////////////////////////////////////////////

#define FOR_EACH_TEST_FUN(DO)                                                                      \
  DO(mini_test)                                                                                    
  /* DO(test_setup_is_okay)                                                                           \ */
  /* DO(newly_allocated_ae_obj_is_inside_pool)                                                        \ */
  /* DO(newly_allocated_ae_obj_type_is_AE_INVALID)                                                    \ */
  /* DO(newly_initialized_ae_obj_has_correct_type_field)                                              \ */
  /* DO(newly_initialized_ae_obj_has_zeroed_data_fields)                                              \ */
  /* DO(unsafe_move_an_ae_obj)                                                                        \ */
  /* DO(clone_a_simple_ae_obj)                                                                        \ */
  /* DO(consed_list_tests)                                                                            \ */
  /* DO(pushed_list_tests)                                                                            \ */
  /* DO(pushed_and_consed_lists_write_identically)                                                    \ */
  /* DO(intern_symbols)                                                                               \ */
  /* DO(remove_interned_elem_from_list)                                                               \ */
  /* DO(truth)                                                                                        \ */
  /* DO(equal)                                                                                        \ */
  /* DO(fwrite_lengths) */

#define pair(fun) { #fun, fun },

TEST_LIST = {
  FOR_EACH_TEST_FUN(pair)
  { NULL, NULL }
};
