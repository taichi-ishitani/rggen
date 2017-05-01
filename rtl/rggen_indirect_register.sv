module rggen_indirect_register #(
  parameter int                     ADDRESS_WIDTH = 16,
  parameter bit [ADDRESS_WIDTH-1:0] START_ADDRESS = '0,
  parameter bit [ADDRESS_WIDTH-1:0] END_ADDRESS   = '0,
  parameter int                     INDEX_WIDTH   = 1,
  parameter bit [INDEX_WIDTH-1:0]   INDEX_VALUE   = '0,
  parameter int                     DATA_WIDTH    = 32,
  parameter bit [DATA_WIDTH-1:0]    VALID_BITS    = '1
)(
  rggen_register_if.control register_if,
  input [INDEX_WIDTH-1:0]   i_index
);
  logic select;
  logic address_match;

  assign  select              = (address_match && (i_index == INDEX_VALUE)) ? 1'b1 : 1'b0;
  assign  register_if.select  = select;
  assign  register_if.ready   = register_if.request & select;

  rggen_default_register #(
    .ADDRESS_WIDTH  (ADDRESS_WIDTH  ),
    .START_ADDRESS  (START_ADDRESS  ),
    .END_ADDRESS    (END_ADDRESS    ),
    .DATA_WIDTH     (DATA_WIDTH     ),
    .VALID_BITS     (VALID_BITS     ),
    .INTERNAL_USE   (1              )
  ) u_register (register_if, address_match);
endmodule
