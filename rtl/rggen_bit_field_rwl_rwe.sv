module rggen_bit_field_rwl_rwe
  import rggen_rtl_pkg::*;
#(
  parameter rggen_rwle_mode   MODE          = RGGEN_LOCK_MODE,
  parameter int               WIDTH         = 1,
  parameter bit [WIDTH-1:0]   INITIAL_VALUE = '0
)(
  input               clk,
  input               rst_n,
  input               i_lock_or_enable,
  interface           bit_field_if,
  output  [WIDTH-1:0] o_value
);
  logic [WIDTH-1:0] value;

  assign  o_value                 = value;
  assign  bit_field_if.value      = value;
  assign  bit_field_if.read_data  = value;
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      value <= INITIAL_VALUE;
    end
    else if ((i_lock_or_enable == MODE) && bit_field_if.write_access) begin
      value <= (value                   & (~bit_field_if.write_mask))
             | (bit_field_if.write_data &   bit_field_if.write_mask );
    end
  end
endmodule
