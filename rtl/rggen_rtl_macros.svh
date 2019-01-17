`ifndef RGGEN_RTL_MACROS_SVH
`define RGGEN_RTL_MACROS_SVH

`define rggen_connect_bit_field_if(RIF, FIF, MSB, LSB) \
assign  FIF.read_access         = RIF.read_access; \
assign  FIF.write_access        = RIF.write_access; \
assign  FIF.write_data          = RIF.write_data[MSB:LSB]; \
assign  FIF.write_mask          = RIF.write_mask[MSB:LSB]; \
assign  RIF.value[MSB:LSB]      = FIF.value; \
assign  RIF.read_data[MSB:LSB]  = FIF.read_data;

`endif
