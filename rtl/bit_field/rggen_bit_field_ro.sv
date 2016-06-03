module rggen_bit_field_ro #(
  parameter WIDTH = 1
)(
  input   [WIDTH-1:0] i_value,
  output  [WIDTH-1:0] o_value
);
  assign  o_value = i_value;
endmodule
