module rggen_host_if_axi4lite
  import  rggen_rtl_pkg::*;
#(
  parameter int             LOCAL_ADDRESS_WIDTH = 16,
  parameter int             DATA_WIDTH          = 32,
  parameter rggen_direction ACCESS_PRIORITY     = RGGEN_WRITE
)(
  input                   clk,
  input                   rst_n,
  rggen_axi4lite_if.slave axi4lite_if,
  rggen_bus_if.master     bus_if
);
  //  TODO
endmodule
