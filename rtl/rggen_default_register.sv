module rggen_default_register #(
  parameter int                     ADDRESS_WIDTH = 16,
  parameter bit [ADDRESS_WIDTH-1:0] START_ADDRESS = '0,
  parameter bit [ADDRESS_WIDTH-1:0] END_ADDRESS   = '0,
  parameter int                     DATA_WIDTH    = 32
)(
  rggen_register_if.slave   register_if,
  rggen_bit_field_if.master bit_field_if
);
  import  rggen_rtl_pkg::*;

  logic address_match;

  rggen_address_decoder #(
    ADDRESS_WIDTH, START_ADDRESS, END_ADDRESS, DATA_WIDTH
  ) u_address_decoder (register_if.address, address_match);

  assign  register_if.select    = address_match;
  assign  register_if.ready     = (register_if.request && address_match) ? 1'b1 : 1'b0;
  assign  register_if.read_data = bit_field_if.read_data;
  assign  register_if.value     = bit_field_if.value;
  assign  register_if.status    = RGGEN_OKAY;

  assign  bit_field_if.write_access = (
    register_if.request && address_match && (register_if.direction == RGGEN_WRITE)
  ) ? 1'b1 : 1'b0;
  assign  bit_field_if.read_access  = (
    register_if.request && address_match && (register_if.direction == RGGEN_READ)
  ) ? 1'b1 : 1'b0;
  assign  bit_field_if.write_data   = register_if.write_data;
  assign  bit_field_if.write_mask   = register_if.write_mask;
endmodule
