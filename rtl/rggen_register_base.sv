module rggen_register_base #(
  parameter int                     ADDRESS_WIDTH               = 16,
  parameter bit [ADDRESS_WIDTH-1:0] START_ADDRESS               = '0,
  parameter bit [ADDRESS_WIDTH-1:0] END_ADDRESS                 = '0,
  parameter int                     DATA_WIDTH                  = 32,
  parameter int                     TOTAL_BIT_FIELDS            = 1,
  parameter int                     MSB_LIST[TOTAL_BIT_FIELDS]  = '{0},
  parameter int                     LSB_LIST[TOTAL_BIT_FIELDS]  = '{0}
)(
  rggen_register_if.slave   register_if,
  rggen_bit_field_if.master bit_field_if[TOTAL_BIT_FIELDS],
  input logic               i_additional_match
);
  import  rggen_rtl_pkg::*;

  logic                   address_match;
  logic                   select;
  logic [DATA_WIDTH-1:0]  value;
  logic [DATA_WIDTH-1:0]  read_data;
  genvar                  g_i;

  //  Decode Address
  assign  select  = (address_match && i_additional_match) ? 1'b1 : 1'b0;
  rggen_address_decoder #(
    ADDRESS_WIDTH, START_ADDRESS, END_ADDRESS, DATA_WIDTH
  ) u_address_decoder (register_if.address, address_match);

  //  Drive Register IF
  assign  register_if.select    = select;
  assign  register_if.ready     = (register_if.request && select) ? 1'b1 : 1'b0;
  assign  register_if.value     = value;
  assign  register_if.read_data = read_data;
  assign  register_if.status    = RGGEN_OKAY;

  //  Drive Bit Field IF
  generate for (g_i = 0;g_i < TOTAL_BIT_FIELDS;++g_i) begin : bit_fields
    localparam  int MSB   = MSB_LIST[g_i];
    localparam  int LSB   = LSB_LIST[g_i];
    localparam  int WIDTH = MSB - LSB + 1;

    assign  bit_field_if[g_i].read_access   = (
      register_if.request && select && (register_if.direction == RGGEN_READ)
    ) ? 1'b1 : 1'b0;
    assign  bit_field_if[g_i].write_access  = (
      register_if.request && select && (register_if.direction == RGGEN_WRITE)
    ) ? 1'b1 : 1'b0;

    assign  bit_field_if[g_i].write_data[WIDTH-1:0] = register_if.write_data[MSB:LSB];
    assign  bit_field_if[g_i].write_mask[WIDTH-1:0] = register_if.write_mask[MSB:LSB];

    assign  value[MSB:LSB]      = bit_field_if[g_i].value[WIDTH-1:0];
    assign  read_data[MSB:LSB]  = bit_field_if[g_i].read_data[WIDTH-1:0];
  end endgenerate

  //  Drive Dummy Data
  generate for (g_i = 0;g_i < DATA_WIDTH;++g_i) begin : dummy
    if (!is_valid_bit(g_i)) begin
      assign  value[g_i]      = 1'b0;
      assign  read_data[g_i]  = 1'b0;
    end
  end endgenerate

  function automatic bit is_valid_bit(int index);
    for (int i = 0;i < TOTAL_BIT_FIELDS;++i) begin
      if ((index >= LSB_LIST[i]) && (index <= MSB_LIST[i])) begin
        return 1;
      end
    end
    return 0;
  endfunction
endmodule
