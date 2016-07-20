module rggen_address_decoder #(
  parameter ADDRESS_WIDTH       = 16,
  parameter START_ADDRESS       = 'h00,
  parameter END_ADDRESS         = 'h00,
  parameter USE_SHADOW_INDEX    = 0,
  parameter SHADOW_INDEX_WIDTH  = 1,
  parameter SHADOW_INDEX_VALUE  = 'h00
)(
  input   [ADDRESS_WIDTH-1:0]       i_address,
  input   [SHADOW_INDEX_WIDTH-1:0]  i_shadow_index,
  output                            o_select
);
  logic match_address;
  logic match_shadow_index;

  assign  o_select  = (match_address && match_shadow_index) ? 1'b1 : 1'b0;

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
    if (USE_SHADOW_INDEX) begin
      assign  match_shadow_index  = (i_shadow_index == SHADOW_INDEX_VALUE) ? 1'b1 : 1'b0;
    end
    else begin
      assign  match_shadow_index  = 1'b1;
    end
  endgenerate
endmodule
