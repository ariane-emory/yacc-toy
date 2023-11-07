#pragma once

#include <stdbool.h>

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
typedef enum {
  FRS_READ,
  FRS_NO_ALLOC,
  FRS_NO_OPEN
} fread_string_state_t;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct fread_string_t {
  fread_string_state_t state;
  char *               buffer;
  size_t               length;
} fread_string_t;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
typedef enum {
  CCOS_STATE_COMPLETED,
  CCOS_STATE_NO_EXEC,
  CCOS_STATE_NO_PIPE,
  CCOS_STATE_NO_FORK,
} capture_command_output_state_t;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct capture_command_output_t {
  capture_command_output_state_t state;
  char *                          stdout;
  size_t                          stdout_size;
  char *                          stderr;
  size_t                          stderr_size;
  int                             exit;
} capture_command_output_t;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// char *                ae_sys_read_from_fd(int fd, size_t * const size);
capture_command_output_t ae_sys_capture_command_output(char * const command);
bool                     ae_sys_expand_tilde(const char * const path, char ** expanded_path);
bool                     ae_sys_file_exists(const char * const filename);
fread_string_t           ae_sys_file_read_string(const char * const filename);
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
