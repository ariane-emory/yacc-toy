#include "obj.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
// data
////////////////////////////////////////////////////////////////////////////////////////////////////

#define free_list_size (1 << 16)

extern char       mem[free_list_size];
extern ae_obj_t * program;
extern FILE *     yyin;

////////////////////////////////////////////////////////////////////////////////////////////////////
// preface
////////////////////////////////////////////////////////////////////////////////////////////////////

void       preface(void); 
ae_obj_t * setup_root_env(void);
void       paint_parsed(void);
bool       setopts(int argc, char * argv[]);
ae_obj_t * load_file(const char * filename, bool * const failed_to_open);
