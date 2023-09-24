#include "ae_util.h"

char log_buffer[64];

void obj_log(ae_obj_t * obj, char * desc) {
  NL;
  PR("%-20s %018p ", desc, obj);
  SPC;
  ae_put(obj);
  SPC;
  ae_write(obj);
}
