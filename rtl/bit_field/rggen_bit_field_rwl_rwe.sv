module rggen_bit_field_rwl_rwe #(
  parameter LOCK_MODE     = 1,
  parameter WIDTH         = 1,
  parameter INITIAL_VALUE = 0
)(
  input               clk,
  input               rst_n,
  input               i_lock_or_enable,
  input               i_command_valid,
  input               i_select,
  input               i_write,
  input   [WIDTH-1:0] i_write_data,
  input   [WIDTH-1:0] i_write_mask,
  output  [WIDTH-1:0] o_value
);
  logic [WIDTH-1:0] value;
  logic             writable;

  assign  o_value   = value;
  assign  writable  = (LOCK_MODE) ? !i_lock_or_enable : i_lock_or_enable;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      value <= INITIAL_VALUE;
    end
    else if (writable && i_command_valid && i_select && i_write) begin
      value <= (i_write_data & ( i_write_mask))
             | (value        & (~i_write_mask));
    end
  end
endmodule
