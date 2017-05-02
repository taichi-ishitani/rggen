module rggen_bit_field_w01s_w01c
  import  rggen_rtl_pkg::*;
#(
  parameter rggen_rwsc_mode   MODE            = RGGEN_SET_MODE,
  parameter bit               SET_CLEAR_VALUE = 1'b0,
  parameter int               MSB             = 0,
  parameter int               LSB             = 0,
  parameter logic [MSB-LSB:0] INITIAL_VALUE   = '0
)(
  input                   clk,
  input                   rst_n,
  input   [MSB-LSB:0]     i_set_or_clear,
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
    else begin
      value <= get_next_value(
        i_set_or_clear,
        register_if.write_access(),
        register_if.write_data,
        register_if.wrtei_mask,
        value
      );
    end
  end

  function automatic logi [MSB-LSB:0]  get_next_value(
    input [MSB-LSB:0] set_or_clear,
    input             write_access,
    input [MSB-LSB:0] write_data,
    input [MSB-LSB:0] write_mask,
    input [MSB-LSB:0] current_value
  );
    logic [MSB-LSB:0] control_value;
    logic [MSB-LSB:0] set;
    logic [MSB-LSB:0] clear;
    if (write_access) begin
      control_value = write_mask & ((SET_CLEAR_VALUE) ? write_data : ~write_data);
    end
    else begin
      control_value = '0;
    end
    if (MODE == RGGEN_SET_MODE) begin
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