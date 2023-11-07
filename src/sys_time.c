#include <time.h>

#include "sys_time.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
// now
////////////////////////////////////////////////////////////////////////////////////////////////////
long long int ae_sys_time_now(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (long long) ts.tv_sec * 1000LL + ts.tv_nsec / 1000000LL; // Convert seconds to milliseconds and add nanoseconds converted to milliseconds
}
////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////
// now_us
////////////////////////////////////////////////////////////////////////////////////////////////////
long long int ae_sys_time_now_us(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (long long) ts.tv_sec * 1000000LL + ts.tv_nsec / 1000LL; // Convert seconds to microseconds and add nanoseconds converted to microseconds
}
////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////
// elapsed
////////////////////////////////////////////////////////////////////////////////////////////////////
long long int ae_sys_time_elapsed(long long int time) {
  return ((long long int) (ae_sys_time_now() - time));
}
////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////
// elapsed_us
////////////////////////////////////////////////////////////////////////////////////////////////////
long long int ae_sys_time_elapsed_us(long long int time_us) {
  return ((long long int) (ae_sys_time_now_us() - time_us));
}
////////////////////////////////////////////////////////////////////////////////////////////////////

