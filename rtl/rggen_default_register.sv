module rggen_default_register #(
  parameter int                     ADDRESS_WIDTH = 16,
  parameter bit [ADDRESS_WIDTH-1:0] START_ADDRESS = '0,
  parameter bit [ADDRESS_WIDTH-1:0] END_ADDRESS   = '0,
  parameter int                     DATA_WIDTH    = 32,
  parameter bit [DATA_WIDTH-1:0]    VALID_BITS    = '1,
  parameter bit [DATA_WIDTH-1:0]    READABLE_BITS = '1,
  parameter bit                     INTERNAL_USE  = 0
)(
  rggen_register_if.control register_if,
  output                    o_select
);
  import  rggen_rtl_pkg::*;

  localparam  int                         LSB       = $clog2(DATA_WIDTH / 8);
  localparam  bit [ADDRESS_WIDTH-LSB-1:0] SADDRESS  = START_ADDRESS >> LSB;
  localparam  bit [ADDRESS_WIDTH-LSB-1:0] EADDRESS  = END_ADDRESS >> LSB;

  logic select;

  assign  o_select  = select;
  generate if (SADDRESS == EADDRESS) begin
    assign  select  = (
      register_if.address[ADDRESS_WIDTH-1:LSB] == SADDRESS
    ) ? 1'b1 : 1'b0;
  end
  else begin
    assign  select  = (
      (register_if.address[ADDRESS_WIDTH-1:LSB] >= SADDRESS) &&
      (register_if.address[ADDRESS_WIDTH-1:LSB] <= EADDRESS)
    ) ? 1'b1 : 1'b0;
  end endgenerate
  generate if (!INTERNAL_USE) begin
    assign  register_if.select  = select;
    assign  register_if.ready   = register_if.request & select;
  end endgenerate

  generate if (1) begin
    genvar  i;
    for (i = 0;i < DATA_WIDTH;i++) begin
      if (!VALID_BITS[i]) begin
        assign  register_if.value[i]  = 1'b0;
      end
      if (!READABLE_BITS[i]) begin
        assign  register_if.read_data[i]  = 1'b0;
      end
    end
  end endgenerate

  assign  register_if.status  = RGGEN_OKAY;
endmodule
