module rggen_host_if_apb #(
  parameter int LOCAL_ADDRESS_WIDTH = 16,
  parameter int DATA_WIDTH          = 32,
  parameter int TOTAL_REGISTERS     = 1
)(
  input logic               clk,
  input logic               rst_n,
  rggen_apb_if.slave        apb_if,
  rggen_register_if.master  register_if[TOTAL_REGISTERS]
);
  import  rggen_rtl_pkg::*;

  rggen_bus_if #(LOCAL_ADDRESS_WIDTH, DATA_WIDTH) bus_if();

  assign  apb_if.pready       = bus_if.done;
  assign  apb_if.prdata       = bus_if.read_data;
  assign  apb_if.pslverr      = bus_if.status[1];
  assign  bus_if.request      = apb_if.psel;
  assign  bus_if.address      = apb_if.paddr[LOCAL_ADDRESS_WIDTH-1:0];
  assign  bus_if.direction    = rggen_direction'(apb_if.pwrite);
  assign  bus_if.write_data   = apb_if.pwdata;
  assign  bus_if.write_strobe = apb_if.pstrb;

  rggen_bus_splitter #(
    DATA_WIDTH, TOTAL_REGISTERS
  ) u_bus_splitter (
    clk, rst_n, bus_if, register_if
  );
endmodule
