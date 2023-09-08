#pragma once

#include "ae_type.h"
#include "ae_data.h"

////////////////////////////////////////////////////////////////////////////////
// Object type
////////////////////////////////////////////////////////////////////////////////

typedef struct ae_object_t {
  ae_type_t                 type;
  char *                    c_str;
  ae_data_t                 data;
} ae_object_t;

//------------------------------------------------------------------------------

void               ae_object_init(ae_object_t * const this);
const char * const ae_object_str(const ae_object_t * const this);
void               ae_object_move(ae_object_t * const this, ae_object_t * const that);
