#pragma once

/////////////////////////////////////////////////////////////////////////////////
// List type
////////////////////////////////////////////////////////////////////////////////

typedef void   (*ae_list_each_fun)(void * const);

typedef struct ae_node_t {
  void *               head;
  struct ae_node_t *   tail;
} ae_node_t;

typedef ae_node_t * ae_list_t;

//------------------------------------------------------------------------------

ae_node_t *        ae_list_push_back(      ae_list_t * const this, void * const obj);

void               ae_list_each (      ae_list_t * const this, ae_list_each_fun fun);

void               ae_node_init     (      ae_node_t * const this);
size_t             ae_node_length   (const ae_node_t * const this);
ae_node_t *        ae_node_push_back(      ae_node_t * const this, void * const obj);
void               ae_node_each     (      ae_node_t * const this, ae_list_each_fun fun);
