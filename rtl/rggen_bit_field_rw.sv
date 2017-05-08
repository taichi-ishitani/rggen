module rggen_bit_field_rw #(
  parameter int             WIDTH         = 1,
  parameter bit [WIDTH-1:0] INITIAL_VALUE = '0
)(
  input               clk,
  input               rst_n,
  interface           bit_field_if,
  output  [WIDTH-1:0] o_value
);
  logic [WIDTH-1:0] value;

  assign  o_value                 = value;
  assign  bit_field_if.value      = value;
  assign  bit_field_if.read_data  = value;
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      value <= INITIAL_VALUE;
    end
    else if (bit_field_if.write_access) begin
      value <= (value                   & (~bit_field_if.write_mask))
             | (bit_field_if.write_data &   bit_field_if.write_mask );
    end
  end
endmodule
