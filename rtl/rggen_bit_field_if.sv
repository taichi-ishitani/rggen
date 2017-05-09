interface rggen_bit_field_if #(
  parameter int DATA_WIDTH  = 32
)();
  logic                   read_access;
  logic                   write_access;
  logic [DATA_WIDTH-1:0]  write_data;
  logic [DATA_WIDTH-1:0]  write_mask;
  logic [DATA_WIDTH-1:0]  value;
  logic [DATA_WIDTH-1:0]  read_data;

  modport master (
    output  read_access,
    output  write_access,
    output  write_data,
    output  write_mask,
    input   value,
    input   read_data
  );

  modport slave (
    input   read_access,
    input   write_access,
    input   write_data,
    input   write_mask,
    output  value,
    output  read_data
  );
endinterface
