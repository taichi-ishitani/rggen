module rggen_bit_field_rwl_rwe
  import rgge_rtl_type_pkg::*;
#(
  parameter rggen_rwle_mode   MODE          = RGGEN_LOCK_MODE,
  parameter int               MSB           = 0,
  parameter int               LSB           = 0,
  parameter logic [MSB-LSB:0] INITIAL_VALUE = '0
)(
  input                   clk,
  input                   rst_n,
  input                   i_lock_or_enable,
  rggen_register_if.data  register_if,
  output  [MSB-LSB:0]     o_value
);
  logic [MSB-LSB:0] value;

  assign  o_value                         = value;
  assign  register_if.read_data[MSB:LSB]  = value;
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      value <= INITIAL_VALUE;
    end
    else if ((i_lock_or_enable == MODE) && register_if.write_access()) begin
      value <= (value                           & (~register_if.write_mask[MSB:LSB]))
             | (register_if.write_data[MSB:LSB] &   register_if.write_mask[MSB:LSB] );
    end
  end
endmodule
