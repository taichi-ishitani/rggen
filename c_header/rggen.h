#ifndef RGGEN_H
#define RGGEN_H

#include <stdint.h>

typedef uint8_t   rggen_uint8;
typedef uint16_t  rggen_uint16;
typedef uint32_t  rggen_uint32;
typedef uint64_t  rggen_uint64;

#define RGGEN_EXTERNAL_REGISTERS(SIZE, TYPE) \
union { \
  rggen_uint8 array[SIZE]; \
  TYPE        body; \
}

#endif
