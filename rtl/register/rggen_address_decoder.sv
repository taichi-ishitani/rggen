module rggen_address_decoder #(
  parameter ADDRESS_WIDTH         = 16,
  parameter START_ADDRESS         = 'h00,
  parameter END_ADDRESS           = 'h00,
  parameter INDIRECT_REGISTER     = 0,
  parameter INDIRECT_INDEX_WIDTH  = 1,
  parameter INDIRECT_INDEX_VALUE  = 'h00
)(
  input   [ADDRESS_WIDTH-1:0]         i_address,
  input   [INDIRECT_INDEX_WIDTH-1:0]  i_indirect_index,
  output                              o_select
);
  logic match_address;
  logic match_indirect_index;

  assign  o_select  = (match_address && match_indirect_index) ? 1'b1 : 1'b0;

  generate
    if (START_ADDRESS == END_ADDRESS) begin
      assign  match_address = (i_address == START_ADDRESS) ? 1'b1 : 1'b0;
    end
    else begin
      assign  match_address = (
        (i_address >= START_ADDRESS) && (i_address <= END_ADDRESS)
      ) ? 1'b1 : 1'b0;
    end
  endgenerate

  generate
    if (INDIRECT_REGISTER) begin
      assign  match_indirect_index  = (i_indirect_index == INDIRECT_INDEX_VALUE) ? 1'b1 : 1'b0;
    end
    else begin
      assign  match_indirect_index  = 1'b1;
    end
  endgenerate
endmodule
