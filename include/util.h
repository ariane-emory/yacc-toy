#pragma once

////////////////////////////////////////////////////////////////////////////////////////////////////
// jump-return and error bailing
////////////////////////////////////////////////////////////////////////////////////////////////////
#define BAIL_IF_ERROR(obj)                                                                         \
  ({                                                                                               \
    CAPTURE(obj);                                                                                  \
    if (ERRORP(CAPTURED)) {                                                                        \
      ret = CAPTURED;                                                                              \
      goto end;                                                                                    \
    }                                                                                              \
    CAPTURED;                                                                                      \
  })
////////////////////////////////////////////////////////////////////////////////////////////////////
#define RETURN(obj)                                                                                \
  ({                                                                                               \
    CAPTURE(obj);                                                                                  \
    ret = CAPTURED;                                                                                \
    goto end;                                                                                      \
  })
////////////////////////////////////////////////////////////////////////////////////////////////////
