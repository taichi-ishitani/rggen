module rggen_default_register #(
  parameter int                     ADDRESS_WIDTH = 16,
  parameter bit [ADDRESS_WIDTH-1:0] START_ADDRESS = '0,
  parameter bit [ADDRESS_WIDTH-1:0] END_ADDRESS   = '0,
  parameter int                     DATA_WIDTH    = 32,
  parameter bit [DATA_WIDTH-1:0]    VALID_BITS    = '0
)(
  rggen_register_if.slave   register_if,
  rggen_bit_field_if.master bit_field_if
);
  rggen_register_base #(
    ADDRESS_WIDTH, START_ADDRESS, END_ADDRESS,
    DATA_WIDTH, VALID_BITS
  ) u_register_base (register_if, bit_field_if, 1'b1);
endmodule
