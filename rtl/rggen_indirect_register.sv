module rggen_indirect_register #(
  parameter int                     ADDRESS_WIDTH               = 16,
  parameter bit [ADDRESS_WIDTH-1:0] START_ADDRESS               = '0,
  parameter bit [ADDRESS_WIDTH-1:0] END_ADDRESS                 = '0,
  parameter int                     INDEX_WIDTH                 = 1,
  parameter bit [INDEX_WIDTH-1:0]   INDEX_VALUE                 = '0,
  parameter int                     DATA_WIDTH                  = 32,
  parameter int                     TOTAL_BIT_FIELDS            = 1,
  parameter int                     MSB_LIST[TOTAL_BIT_FIELDS]  = '{0},
  parameter int                     LSB_LIST[TOTAL_BIT_FIELDS]  = '{0}
)(
  rggen_register_if.slave   register_if,
  rggen_bit_field_if.master bit_field_if[TOTAL_BIT_FIELDS],
  input [INDEX_WIDTH-1:0]   i_index
);
  logic index_match;

  assign  index_match = (i_index == INDEX_VALUE) ? 1'b1 : 1'b0;
  rggen_register_base #(
    ADDRESS_WIDTH, START_ADDRESS, END_ADDRESS,
    DATA_WIDTH,
    TOTAL_BIT_FIELDS, MSB_LIST, LSB_LIST
  ) u_register_base (register_if, bit_field_if, index_match);
endmodule
