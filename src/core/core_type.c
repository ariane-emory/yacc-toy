#include "core_includes.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
// _type
////////////////////////////////////////////////////////////////////////////////////////////////////

DEF_CORE_FUN(type) {
  const char * type = GET_TYPE_STR(CAR(args));
  /* */ char * tmp  = free_list_malloc(strlen(type) + 2);

  sprintf(tmp, ":%s", type);

  ae_obj_t   * sym  = SYM(tmp);

  free_list_free(tmp);

  RETURN(sym);

  END_DEF_CORE_FUN(type);
}
