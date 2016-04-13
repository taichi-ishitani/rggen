module rggen_address_decoder #(
  parameter READABLE            = 1,
  parameter WRITABLE            = 1,
  parameter ADDRESS_WIDTH       = 16,
  parameter START_ADDRESS       = 'h00,
  parameter END_ADDRESS         = 'h00,
  parameter USE_SHADOW_INDEX    = 0,
  parameter SHADOW_INDEX_WIDTH  = 1,
  parameter SHADOW_INDEX_VALUE  = 'h00
)(
  input                             i_read,
  input                             i_write,
  input   [ADDRESS_WIDTH-1:0]       i_address,
  input   [SHADOW_INDEX_WIDTH-1:0]  i_shadow_index,
  output                            o_select
);
  localparam  READ_ONLY   = (READABLE && (!WRITABLE)) ? 1 : 0;
  localparam  WRITE_ONLY  = (WRITABLE && (!READABLE)) ? 1 : 0;

  logic match;
  logic match_address;
  logic match_shadow_index;

  assign  match = (match_address && match_shadow_index) ? 1'b1 : 1'b0;

  if (START_ADDRESS == END_ADDRESS) begin
    assign  match_address = (i_address == START_ADDRESS) ? 1'b1 : 1'b0;
  end
  else begin
    assign  match_address = (i_address inside {[START_ADDRESS:END_ADDRESS]}) ? 1'b1 : 1'b0;
  end

  if (USE_SHADOW_INDEX) begin
    assign  match_shadow_index  = (i_shadow_index == SHADOW_INDEX_VALUE) ? 1'b1 : 1'b0;
  end
  else begin
    assign  match_shadow_index  = 1'b1;
  end

  if (READ_ONLY) begin
    assign  o_select  = (match && i_read) ? 1'b1 : 1'b0;
  end
  else if (WRITE_ONLY) begin
    assign  o_select  = (match && i_write) ? 1'b1 : 1'b0;
  end
  else begin
    assign  o_select  = match;
  end
endmodule
