#include "ae_util.h"

char obj_log_buffer[64];

void obj_log(const ae_obj_t * const obj, char * desc) {
  NL;
  PR("%-24s %018p ", desc, obj);
  SPC;
  ae_put(obj);
  SPC;
  ae_write(obj);
  fflush(stdout);
}
