#include "ae_util.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
// Data
////////////////////////////////////////////////////////////////////////////////////////////////////

char obj_log_buffer[256] = { 0 };
int  indentation         =   0;

////////////////////////////////////////////////////////////////////////////////////////////////////
// obj_log
////////////////////////////////////////////////////////////////////////////////////////////////////

int obj_log(const ae_obj_t * const obj, char * desc) {
  NL;

  int written = 0;

  while (written++ < (indentation << 1)) SPC;
  
  written += PR("%s ", desc);

  while (written++ < 72) SPC;
  
  written += WRITE(obj);

  fflush(stdout);
  
  return written;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// indent
////////////////////////////////////////////////////////////////////////////////////////////////////

void indent(void) {
  indentation += 1;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// outdent
////////////////////////////////////////////////////////////////////////////////////////////////////

void outdent(void) {
  indentation    -= 1;

  if (indentation < 0) {
    FPR(stderr,
        "\nBANGED AGAINST THE LEFT MARGIN, THIS SHOULDN'T HAPPEN AND PROBABLY INDICATES "
        "A PROGRAMMER ERROR!\n");

#ifded AE_DEADLY_MARGIN
    assert(((void)"hit the margin", 0));
#endif
    
    indentation   = 0;
  }
}
