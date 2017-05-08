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
  wire  [DATA_WIDTH-1:0]    read_data;
  wire  [DATA_WIDTH-1:0]    value;
  rggen_status              status;

  function automatic logic write_access();
    return (request && select && (direction == RGGEN_WRITE)) ? 1'b1 : 1'b0;
  endfunction

  function automatic logic read_access();
    return (request && select && (direction == RGGEN_READ)) ? 1'b1 : 1'b0;
  endfunction

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

  modport control (
    input   request,
    input   address,
    output  select,
    input   direction,
    output  ready,
    output  read_data,
    output  value,
    output  status
  );

  modport data (
    input   request,
    input   select,
    input   direction,
    input   write_data,
    input   write_strobe,
    input   write_mask,
    output  read_data,
    output  value,
    import  write_access,
    import  read_access
  );
endinterface
