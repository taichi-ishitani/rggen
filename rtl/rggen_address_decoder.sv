module rggen_address_decoder #(
  parameter int                     ADDRESS_WIDTH = 8,
  parameter bit [ADDRESS_WIDTH-1:0] STAET_ADDRESS = '0,
  parameter bit [ADDRESS_WIDTH-1:0] END_ADDRESS   = '0,
  parameter int                     DATA_WIDTH    = 32
)(
  input   [ADDRESS_WIDTH-1:0] i_address,
  output                      o_match
);
  localparam  int                       LSB       = $clog2(DATA_WIDTH / 8);
  localparam  bit [ADDRESS_WIDTH-LSB:0] SADDRESS  = STAET_ADDRESS[ADDRESS_WIDTH-1:LSB];
  localparam  bit [ADDRESS_WIDTH-LSB:0] EADDRESS  = END_ADDRESS[ADDRESS_WIDTH-1:LSB];

  generate if (SADDRESS == EADDRESS) begin
    assign  o_match = (i_address[ADDRESS_WIDTH-1:LSB] == SADDRESS) ? 1'b1 : 1'b0;
  end
  else begin
    assign  o_match = (
      (i_address[ADDRESS_WIDTH-1:LSB] >= SADDRESS) &&
      (i_address[ADDRESS_WIDTH-1:LSB] <= EADDRESS)
    ) ? 1'b1 : 1'b0;
  end endgenerate
endmodule
