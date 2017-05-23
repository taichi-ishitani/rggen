module rggen_register_base #(
  parameter int                     ADDRESS_WIDTH = 16,
  parameter bit [ADDRESS_WIDTH-1:0] START_ADDRESS = '0,
  parameter bit [ADDRESS_WIDTH-1:0] END_ADDRESS   = '0,
  parameter int                     DATA_WIDTH    = 32,
  parameter bit [DATA_WIDTH-1:0]    VALID_BITS    = '0
)(
  rggen_register_if.slave   register_if,
  rggen_bit_field_if.master bit_field_if,
  input logic               i_additional_match
);
  import  rggen_rtl_pkg::*;

  logic   address_match;
  logic   select;
  genvar  g_i;

  //  Decode Address
  assign  select  = (address_match && i_additional_match) ? 1'b1 : 1'b0;
  rggen_address_decoder #(
    ADDRESS_WIDTH, START_ADDRESS, END_ADDRESS, DATA_WIDTH
  ) u_address_decoder (register_if.address, address_match);

  //  Drive Register IF
  assign  register_if.select    = select;
  assign  register_if.ready     = (register_if.request && select) ? 1'b1 : 1'b0;
  assign  register_if.status    = RGGEN_OKAY;

  generate for (g_i = 0;g_i < DATA_WIDTH;++g_i) begin : g
    if (VALID_BITS[g_i]) begin
      assign  register_if.value[g_i]      = bit_field_if.value[g_i];
      assign  register_if.read_data[g_i]  = bit_field_if.read_data[g_i];
    end
    else begin
      assign  register_if.value[g_i]      = '0;
      assign  register_if.read_data[g_i]  = '0;
    end
  end endgenerate

  //  Drive Bit Field IF
  assign  bit_field_if.read_access  = (
    register_if.request && select && (register_if.direction == RGGEN_READ)
  ) ? 1'b1 : 1'b0;
  assign  bit_field_if.write_access = (
    register_if.request && select && (register_if.direction == RGGEN_WRITE)
  ) ? 1'b1 : 1'b0;
  assign  bit_field_if.write_data   = register_if.write_data;
  assign  bit_field_if.write_mask   = get_write_mask(register_if.write_strobe);

  function automatic logic [DATA_WIDTH-1:0] get_write_mask(logic [DATA_WIDTH/8-1:0] strobe);
    logic [DATA_WIDTH-1:0]  mask;
    for (int i= 0;i < DATA_WIDTH;i += 8) begin
      mask[i+:8]  = {8{strobe[i/8]}};
    end
    return mask;
  endfunction
endmodule
