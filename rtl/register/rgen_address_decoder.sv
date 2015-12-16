module rgen_address_decoder #(
  parameter ADDRESS_WIDTH = 16,
  parameter READABLE      = 1,
  parameter WRITABLE      = 1,
  parameter START_ADDRESS = 'h00,
  parameter END_ADDRESS   = 'h00
)(
  input   [ADDRESS_WIDTH-1:0] i_address,
  input                       i_read,
  input                       i_write,
  output                      o_select
);
  localparam  READ_ONLY   = (READABLE && (!WRITABLE)) ? 1 : 0;
  localparam  WRITE_ONLY  = (WRITABLE && (!READABLE)) ? 1 : 0;
  localparam  RESERVED    = (!(READABLE || WRITABLE)) ? 1 : 0;

  logic match_address;

  if (RESERVED) begin
    assign  match_address = 1'b0;
  end
  else if (START_ADDRESS == END_ADDRESS) begin
    assign  match_address = (i_address == START_ADDRESS) ? 1'b1 : 1'b0;
  end
  else begin
    assign  match_address = (i_address inside {[START_ADDRESS:END_ADDRESS]}) ? 1'b1 : 1'b0;
  end

  if (READ_ONLY) begin
    assign  o_select  = (match_address && i_read) ? 1'b1 : 1'b0;
  end
  else if (WRITE_ONLY) begin
    assign  o_select  = (match_address && i_write) ? 1'b1 : 1'b0;
  end
  else begin
    assign  o_select  = match_address;
  end
endmodule
