#pragma once

#include <stdlib.h>

extern long long int free_list_allocated;

void   free_list_add_block(void * addr, size_t size);
void * free_list_malloc   (size_t size);
void   free_list_free     (void * ptr);
void   free_list_reset    (void);

