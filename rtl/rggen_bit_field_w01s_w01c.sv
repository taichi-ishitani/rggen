module rggen_bit_field_w01s_w01c
  import  rggen_rtl_pkg::*;
#(
  parameter rggen_rwsc_mode   MODE            = RGGEN_SET_MODE,
  parameter bit               SET_CLEAR_VALUE = 1'b0,
  parameter int               WIDTH           = 1,
  parameter bit [WIDTH-1:0]   INITIAL_VALUE   = '0
)(
  input   logic             clk,
  input   logic             rst_n,
  input   logic [WIDTH-1:0] i_set_or_clear,
  rggen_bit_field_if.slave  bit_field_if,
  output  logic [WIDTH-1:0] o_value
);
  logic [WIDTH-1:0] value;

  assign  o_value                           = value;
  assign  bit_field_if.value[WIDTH-1:0]     = value;
  assign  bit_field_if.read_data[WIDTH-1:0] = value;

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      value <= INITIAL_VALUE;
    end
    else begin
      value <= get_next_value();
    end
  end

  function automatic logic [WIDTH-1:0] get_next_value();
    logic [WIDTH-1:0] write_data;
    logic [WIDTH-1:0] write_mask;
    logic [WIDTH-1:0] control_value;
    logic [WIDTH-1:0] set;
    logic [WIDTH-1:0] clear;

    write_data  = bit_field_if.write_data;
    write_mask  = bit_field_if.write_mask;
    if (bit_field_if.write_access) begin
      control_value = write_mask & ((SET_CLEAR_VALUE) ? write_data : ~write_data);
    end
    else begin
      control_value = '0;
    end
    if (MODE == RGGEN_SET_MODE) begin
      set   = control_value;
      clear = i_set_or_clear;
    end
    else begin
      set   = i_set_or_clear;
      clear = control_value;
    end
    return set | (value & (~clear));
  endfunction
endmodule
