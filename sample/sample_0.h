#ifndef SAMPLE_0_H
#define SAMPLE_0_H
#include "rggen.h"
typedef struct {
  rggen_uint32 register_0;
  rggen_uint32 register_1;
  rggen_uint32 register_2;
  rggen_uint32 register_3;
  rggen_uint32 register_4[4];
  rggen_uint32 register_5;
  rggen_uint32 register_6;
  rggen_uint32 register_7;
  rggen_uint32 register_8;
  rggen_uint32 __dummy_0[20];
  RGGEN_EXTERNAL_REGISTERS(128, REGISTER_9) register_9;
} s_sample_0_address_struct;
#endif
