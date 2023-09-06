#include <stdio.h>
#include "mylang-data.h"

void mylang_object_init(mylang_object_t * const mylang_object) {
  mylang_object->type  = ML_INVALID;
  mylang_object->c_str = 0;
}

const char * const mylang_object_str(const mylang_object_t * const mylang_object) {
#define BUFF_LEN 256

  static char buff[BUFF_LEN] = {0};

  snprintf(
    buff,
    BUFF_LEN,
    "('%s', '%s')",
    mylang_type_name(mylang_object->type),
    mylang_object->c_str
  );

  return buff;
}

#define return_str(x) case x: return #x;

const char * const mylang_type_name(const mylang_type_t mylang_type) {
  switch (mylang_type) {
    FOR_LEXED_TYPES_DO(return_str);
  default: return "UNRECOGNIZED!";
  }
}
