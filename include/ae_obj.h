#pragma once

////////////////////////////////////////////////////////////////////////////////
// Typedefs
////////////////////////////////////////////////////////////////////////////////

typedef char * ae_string_t;

////////////////////////////////////////////////////////////////////////////////
// Escaped chars helper
////////////////////////////////////////////////////////////////////////////////

#define FOR_ESCAPED_CHARACTER_DO(DO)                                                                                                        \
  DO('a',  '\a')                                                                                                                            \
  DO('b',  '\b')                                                                                                                            \
  DO('f',  '\f')                                                                                                                            \
  DO('n',  '\n')                                                                                                                            \
  DO('r',  '\r')                                                                                                                            \
  DO('t',  '\t')                                                                                                                            \
  DO('v',  '\v')                                                                                                                            \
  DO('\\', '\\')                                                                                                                            \
  DO('\'', '\'')                                                                                                                            \
  DO('\"', '\"')                                                                                                                            \
  DO('\?', '\?')                                                                                                                         

////////////////////////////////////////////////////////////////////////////////
// Types enum
////////////////////////////////////////////////////////////////////////////////

#define FOR_LEXED_TYPES_DO(DO)                                                                                                              \
  DO(AE_INTEGER_)                                                                                                                           \
  DO(AE_INVALID_)                                                                                                                           \
  DO(AE_CHAR____)                                                                                                                           \
  DO(AE_FLOAT___)                                                                                                                           \
  DO(AE_CONS____)                                                                                                                           \
  DO(AE_LPAREN__)                                                                                                                           \
  DO(AE_RPAREN__)                                                                                                                           \
  DO(AE_QUOTE___)                                                                                                                           \
  DO(AE_RATIONAL)                                                                                                                           \
  DO(AE_INF_____)                                                                                                                           \
  DO(AE_STRING__)                                                                                                                           \
  DO(AE_SYMBOL__)                                                                                                                             

#define enum_node(x) x,

typedef enum {
  AE_FREE____ = 0,
  FOR_LEXED_TYPES_DO(enum_node)
} ae_type_t;

const char * ae_type_str(const ae_type_t this);

struct ae_obj_t;

typedef void              (*ae_obj_each_fun)(struct ae_obj_t * const);
typedef struct ae_obj_t * (*ae_obj_map_fun)(const struct ae_obj_t * const);

////////////////////////////////////////////////////////////////////////////////
// Obj struct
////////////////////////////////////////////////////////////////////////////////

typedef struct ae_obj_t {
  ae_type_t        type;
  union {
    ae_string_t         str_value;
    ae_string_t         sym_value;
    char                char_value;
    int                 int_value;
    double              float_value;
    struct {
      int               numerator_value;
      unsigned int      denominator_value;
    };
    struct {
      struct ae_obj_t * head;
      struct ae_obj_t * tail;
    };
  };
} ae_obj_t;

//------------------------------------------------------------------------------
// Obj's methods
//------------------------------------------------------------------------------

void          ae_obj_init        (      ae_obj_t * const this,  ae_type_t type);
void          ae_obj_unsafe_move (      ae_obj_t * const this,  ae_obj_t * const that);
ae_obj_t *    ae_obj_clone       (const ae_obj_t * const this);

// ugly putses:
void          ae_obj_fput        (const ae_obj_t * const this,  FILE * stream);
void          ae_obj_put         (const ae_obj_t * const this);
// byte-oriented putses:
void          ae_obj_fput_bytes  (const ae_obj_t * const this,  FILE * stream);
void          ae_obj_put_bytes   (const ae_obj_t * const this);
// write:
void          ae_obj_fwrite      (const ae_obj_t * const this,  FILE * stream);
void          ae_obj_write       (const ae_obj_t * const this);

// For AE_CONS____es:
size_t        ae_obj_length      (const ae_obj_t * const this);
void          ae_obj_push_back   (      ae_obj_t * const this, ae_obj_t * const obj);
void          ae_obj_each        (      ae_obj_t * const this, ae_obj_each_fun fun);
ae_obj_t *    ae_obj_map         (      ae_obj_t * const this, ae_obj_map_fun fun);

// This returns a new obj:
ae_obj_t *    ae_obj_cons        (      ae_obj_t * const head, ae_obj_t * const tail);

////////////////////////////////////////////////////////////////////////////////
// pool
////////////////////////////////////////////////////////////////////////////////

#define POOL_SIZE (1 << 7)

#ifdef POOL_SIZE
#  define ALLOC_AE_OBJ pool_alloc_ae_obj()
ae_obj_t * pool_alloc_ae_obj();
void       pool_free_ae_obj(ae_obj_t * const this);
#else
#  define ALLOC_AE_OBJ (puts("Using malloc."), malloc(sizeof(ae_obj_t)))
#endif

