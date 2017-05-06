module rggen_host_if_apb #(
  parameter int LOCAL_ADDRESS_WIDTH = 16
)(
  rggen_apb_if.slave  apb_if,
  rggen_bus_if.master bus_if
);
  assign  apb_if.pready       = bus_if.done;
  assign  apb_if.prdata       = bus_if.read_data;
  assign  apb_if.pslverr      = bus_if.status[1];
  assign  bus_if.request      = bus_if.psel;
  assign  bus_if.address      = bus_if.paddr[LOCAL_ADDRESS_WIDTH-1:0];
  assign  bus_if.direction    = rggen_direction'(apb_if.pwrite);
  assign  bus_if.write_data   = apb_if.pwdata;
  assign  bus_if.write_strobe = apb_if.wstrb;
endmodule
