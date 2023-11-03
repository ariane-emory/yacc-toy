#pragma once

#include <stdbool.h>

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// forward declarations
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct ae_obj_t ae_obj_t;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// types
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct ae_plist_split_around_kvp_t {
  ae_obj_t * before_kvp;
  ae_obj_t * after_kvp;
} ae_plist_split_around_kvp_t;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// convenience macros
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define PSET(plist, key, value)             (ae_plist_set ((plist), (key), (value)))
#define PGET(plist, key)                    (ae_plist_get ((plist), (key)))
#define PHAS(plist, key)                    (ae_plist_contains_key((plist), (key)))
#define PSET_INTERNAL(plist, key, value)    (ae_plist_set_internal((plist), (key), (value)))
#define PSET_MUTATING(plist, key, value)    (ae_plist_set_mutating((plist), (key), (value)))
#define PSET_NONMUTATING(plist, key, value) (ae_plist_set_nonmutating((plist), (key), (value)))
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
ae_plist_split_around_kvp_t ae_plist_split_around_kvp(ae_obj_t * const plist, ae_obj_t * const key);
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool       ae_plist_contains_key                     (ae_obj_t * const plist, ae_obj_t * const key);
ae_obj_t * ae_plist_get                              (ae_obj_t * const plist, ae_obj_t * const key);
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void       ae_plist_remove_mutating                  (ae_obj_t * const plist, ae_obj_t * const key);
ae_obj_t * ae_plist_remove_nonmutating               (ae_obj_t * const plist, ae_obj_t * const key);
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
ae_obj_t * ae_plist_set                              (ae_obj_t *       plist, ae_obj_t * const key, ae_obj_t * const value);
ae_obj_t * ae_plist_set_internal                     (ae_obj_t * const plist, ae_obj_t * const key, ae_obj_t * const value);
void       ae_plist_set_mutating                     (ae_obj_t * const plist, ae_obj_t * const key, ae_obj_t * const value);
ae_obj_t * ae_plist_set_nonmutating                  (ae_obj_t * const plist, ae_obj_t * const key, ae_obj_t * const value);
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
