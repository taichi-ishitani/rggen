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

  function automatic logic write_access();
    return (request && select && (direction == RGGEN_WRITE)) ? 1'b1 : 1'b0;
  endfunction

  function automatic logic read_access();
    return (request && select && (direction == READ)) ? 1'b1 : 1'b0;
  endfunction

  modport master (
    output  request,
    input   select,
    output  address,
    output  direction,
    output  write_data,
    output  write_strobe,
    input   ready,
    input   read_data,
    input   status
  );

  modport control (
    input   request,
    output  select,
    input   direction,
    output  ready,
    output  read_data,
    output  value,
    output  status
  );

  modport data (
    input   write_data,
    input   write_strobe,
    input   write_mask,
    output  read_data,
    output  value,
    import  write_access,
    import  read_access
  );

  generate if (1) begin : g
    genvar  i;
    for (i = 0;i < DATA_WIDTH;i += 8) begin
      assign  write_mask[i:+8]  = {8{write_strobe[i/8]}};
    end
  end endgenerate
endinterface
