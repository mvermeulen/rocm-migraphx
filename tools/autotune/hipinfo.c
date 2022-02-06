/*
 * hipinfo.c - look up database information and other information on hip platform
 */
#include <string.h>
#include "hip/hip_runtime.h"

char *get_architecture(void){
  int count, i;
  hipDeviceProp_t props;

  hipError_t result = hipGetDeviceCount(&count);
  if (result != hipSuccess){
    fprintf(stderr,"unable to call hipGetDeviceCount: %s\n",hipGetErrorString(result));
    return NULL;
  }
  for (i=0;i<count;i++){
    hipSetDevice(i);
    if ((result = hipGetDeviceProperties(&props,i)) != hipSuccess){
      fprintf(stderr,"unable to call hipGetDeviceProperties(%d): %s\n",i,hipGetErrorString(result));
      return NULL;
    }
    return strdup(props.gcnArchName);
  }
  return NULL;
}
