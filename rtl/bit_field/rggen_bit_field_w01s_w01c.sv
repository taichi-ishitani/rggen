module rggen_bit_field_w01s_w01c #(
  parameter WIDTH           = 1,
  parameter INITIAL_VALUE   = 0,
  parameter SET_MODE        = 1,
  parameter SET_CLEAR_VALUE = 0
)(
  input               clk,
  input               rst_n,
  input   [WIDTH-1:0] i_set_or_clear,
  input               i_command_valid,
  input               i_select,
  input               i_write,
  input   [WIDTH-1:0] i_write_data,
  input   [WIDTH-1:0] i_write_mask,
  output  [WIDTH-1:0] o_value
);
  `include  "rggen_bit_field_common.svh"

  logic [WIDTH-1:0] value;

  assign  o_value = value;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      value <= INITIAL_VALUE;
    end
    else begin
      value <= get_next_value(
        i_set_or_clear,
        value,
        i_command_valid,
        i_select,
        i_write,
        i_write_mask,
        i_write_data
      );
    end
  end

  function automatic logic [WIDTH-1:0] get_next_value(
    input [WIDTH-1:0] set_or_clear,
    input [WIDTH-1:0] current_value,
    input             command_valid,
    input             select,
    input             write,
    input [WIDTH-1:0] write_mask,
    input [WIDTH-1:0] write_data
  );
    logic [WIDTH-1:0] control_value;
    logic [WIDTH-1:0] set;
    logic [WIDTH-1:0] clear;
    if (is_write_access(command_valid, select, write)) begin
      control_value = write_mask & ((SET_CLEAR_VALUE) ? write_data : ~write_data);
    end
    else begin
      control_value = '0;
    end
    if (SET_MODE) begin
      set   = control_value;
      clear = set_or_clear;
    end
    else begin
      set   = set_or_clear;
      clear = control_value;
    end
    return set | (current_value & (~clear));
  endfunction
endmodule
