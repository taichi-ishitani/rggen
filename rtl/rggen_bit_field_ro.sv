module rggen_bit_field_ro #(
  parameter int MSB = 0,
  parameter int LSB = 0
)(
  rggen_register_if.data  register_if,
  input [MSB-LSB:0]       i_value
);
  assign  register_if.value[MSB:LSB]      = i_value;
  assign  register_if.read_data[MSB:LSB]  = i_value;
endmodule
