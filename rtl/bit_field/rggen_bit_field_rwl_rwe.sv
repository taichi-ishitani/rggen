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
  `include  "rggen_bit_field_common.svh"

  logic [WIDTH-1:0] value;

  assign  o_value   = value;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      value <= INITIAL_VALUE;
    end
    else if (
      can_write(i_lock_or_enable, i_command_valid, i_select, i_write)
    ) begin
      value <= get_write_data(value, i_write_data, i_write_mask);
    end
  end

  function automatic logic can_write(
    input lock_or_enable,
    input command_valid,
    input select,
    input write
  );
    if (LOCK_MODE) begin
      return (
        (!lock_or_enable) && is_write_access(command_valid, select, write)
      ) ? 1'b1 : 1'b0;
    end
    else begin
      return (
        lock_or_enable && is_write_access(command_valid, select, write)
      ) ? 1'b1 : 1'b0;
    end
  endfunction
endmodule
