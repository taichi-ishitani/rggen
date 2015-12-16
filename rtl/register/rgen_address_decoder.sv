module rgen_address_decoder #(
  parameter ADDRESS_WIDTH = 16,
  parameter READABLE      = 1,
  parameter WRITABLE      = 1,
  parameter START_ADDRESS = 'h00,
  parameter END_ADDRESS   = 'h03
)(
  input   [ADDRESS_WIDTH-1:0] i_address,
  input                       i_read,
  input                       i_write,
  output                      o_select
);
  localparam  BYTE_SIZE       = END_ADDRESS - START_ADDRESS + 1;
  localparam  ADDRESS_LSB     = $clog2(BYTE_SIZE);
  localparam  COMPARE_ADDRESS = START_ADDRESS >> ADDRESS_LSB;

  logic match_address;

  if (READABLE || WRITABLE) begin
    assign  match_address = (i_address[ADDRESS_WIDTH-1:ADDRESS_LSB] == COMPARE_ADDRESS) ? 1'b1 : 1'b0;
  end
  else begin
    assign  match_address = 1'b0;
  end

  if (READABLE && (!WRITABLE)) begin
    assign  o_select  = (match_address && i_read) ? 1'b1 : 1'b0;
  end
  else if ((!READABLE) && WRITABLE) begin
    assign  o_select  = (match_address && i_write) ? 1'b1 : 1'b0;
  end
  else begin
    assign  o_select  = match_address;
  end
endmodule
