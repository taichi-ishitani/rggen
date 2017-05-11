interface rggen_register_if #(
  parameter int ADDRESS_WIDTH = 16,
  parameter int DATA_WIDTH    = 32
)();
  import  rggen_rtl_pkg::*;

  logic                     request;
  logic                     select;
  logic [ADDRESS_WIDTH-1:0] address;
  rggen_direction           direction;
  logic [DATA_WIDTH-1:0]    write_data;
  logic [DATA_WIDTH/8-1:0]  write_strobe;
  logic [DATA_WIDTH-1:0]    write_mask;
  logic                     ready;
  logic [DATA_WIDTH-1:0]    read_data;
  logic [DATA_WIDTH-1:0]    value;
  rggen_status              status;

  modport master (
    output  request,
    input   select,
    output  address,
    output  direction,
    output  write_data,
    output  write_strobe,
    output  write_mask,
    input   ready,
    input   read_data,
    input   status
  );

  modport slave (
    input   request,
    output  select,
    input   address,
    input   direction,
    input   write_data,
    input   write_strobe,
    input   write_mask,
    output  ready,
    output  read_data,
    output  status,
    output  value
  );
endinterface
