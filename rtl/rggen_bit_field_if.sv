interface rggen_bit_field_if #(
  parameter int DATA_WIDTH            = 32,
  parameter int TOTAL_BIT_FIELDS      = 1,
  parameter int MSB[TOTAL_BIT_FIELDS] = '{0},
  parameter int LSB[TOTAL_BIT_FIELDS] = '{0}
)();
  localparam  bit [DATA_WIDTH-1:0]  VALID_BITS  = get_valid_bits();

  logic                   write_access;
  logic                   read_access;
  logic [DATA_WIDTH-1:0]  write_data;
  logic [DATA_WIDTH-1:0]  write_mask;
  logic [DATA_WIDTH-1:0]  value;
  logic [DATA_WIDTH-1:0]  read_data;
  genvar                  g_i;

  modport master (
    output  write_access,
    output  read_access,
    output  write_data,
    output  write_mask,
    input   value,
    input   read_data
  );

  generate
    for (g_i = 0;g_i < TOTAL_BIT_FIELDS;g_i++) begin : bit_fields
      modport slave (
        input   write_access,
        input   read_access,
        input   .write_data(write_data[MSB[g_i]:LSB[g_i]]),
        input   .write_mask(write_mask[MSB[g_i]:LSB[g_i]]),
        output  .value(value[MSB[g_i]:LSB[g_i]]),
        output  .read_data(read_data[MSB[g_i]:LSB[g_i]])
      );
    end
  endgenerate

  generate
    for (g_i = 0;g_i < DATA_WIDTH;g_i++) begin : dummy
      if (!VALID_BITS[g_i]) begin
        assign  value[g_i]      = 1'b0;
        assign  read_data[g_i]  = 1'b0;
      end
    end
  endgenerate

  function automatic bit [DATA_WIDTH-1:0] get_valid_bits();
    bit [DATA_WIDTH-1:0]  mask[TOTAL_BIT_FIELDS];
    for (int i = 0;i < TOTAL_BIT_FIELDS;i++) begin
      mask[i] = '0;
      for (int j = LSB[i];j <= MSB[i];j++) begin
        mask[i][j]  = 1;
      end
    end
    return mask.or();
  endfunction
endinterface
