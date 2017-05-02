interface rggen_bus_if #(
  parameter int ADDRESS_WIDTH = 16,
  parameter int DATA_WIDTH    = 32
)();
  import  rggen_rtl_pkg::*;

  logic                     request;
  logic [ADDRESS_WIDTH-1:0] address;
  rggen_direction           direction;
  logic [DATA_WIDTH-1:0]    write_data;
  logic [DATA_WIDTH/8-1:0]  write_strobe;
  logic                     done;
  logic                     read_done;
  logic                     write_done;
  logic [DATA_WIDTH-1:0]    read_data;
  rggen_status              status;

  modport master (
    output  request,
    output  address,
    output  direction,
    output  write_data,
    output  write_strobe,
    input   done,
    input   read_done,
    input   write_done,
    input   read_data
    input   status
  );

  modport slave (
    input   request,
    input   address,
    input   direction,
    input   write_data,
    input   write_strobe,
    output  done,
    output  read_data,
    output  write_done,
    output  read_data,
    output  status
  );
endinterface
