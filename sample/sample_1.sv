module sample_1 (
  input clk,
  input rst_n,
  rggen_apb_if.slave apb_if,
  output [15:0] o_bit_field_0_0,
  input [15:0] i_bit_field_0_1,
  output [31:0] o_bit_field_1_0,
  input i_bit_field_2_0,
  output o_bit_field_2_1
);
  rggen_bus_if #(7, 32) bus_if();
  rggen_register_if #(7, 32) register_if[3]();
  rggen_host_if_apb #(
    .LOCAL_ADDRESS_WIDTH  (7)
  ) u_host_if (
    .apb_if (apb_if),
    .bus_if (bus_if)
  );
  rggen_bus_splitter #(
    .DATA_WIDTH       (32),
    .TOTAL_REGISTERS  (3)
  ) u_bus_splitter (
    .clk          (clk),
    .rst_n        (rst_n),
    .bus_if       (bus_if),
    .register_if  (register_if)
  );
  rggen_default_register #(
    .ADDRESS_WIDTH  (7),
    .START_ADDRESS  (7'h00),
    .END_ADDRESS    (7'h03),
    .DATA_WIDTH     (32),
    .VALID_BITS     (32'hffffffff),
    .READABLE_BITS  (32'hffffffff)
  ) u_register_0 (
    .register_if  (register_if[0]),
    .o_select     ()
  );
  rggen_bit_field_rw #(
    .MSB            (31),
    .LSB            (16),
    .INITIAL_VALUE  (16'h0000)
  ) u_bit_field_0_0 (
    .clk          (clk),
    .rst_n        (rst_n),
    .register_if  (register_if[0]),
    .o_value      (o_bit_field_0_0)
  );
  rggen_bit_field_ro #(
    .MSB  (15),
    .LSB  (0)
  ) u_bit_field_0_1 (
    .register_if  (register_if[0]),
    .i_value      (i_bit_field_0_1)
  );
  rggen_default_register #(
    .ADDRESS_WIDTH  (7),
    .START_ADDRESS  (7'h04),
    .END_ADDRESS    (7'h07),
    .DATA_WIDTH     (32),
    .VALID_BITS     (32'hffffffff),
    .READABLE_BITS  (32'hffffffff)
  ) u_register_1 (
    .register_if  (register_if[1]),
    .o_select     ()
  );
  rggen_bit_field_rw #(
    .MSB            (31),
    .LSB            (0),
    .INITIAL_VALUE  (32'h00000000)
  ) u_bit_field_1_0 (
    .clk          (clk),
    .rst_n        (rst_n),
    .register_if  (register_if[1]),
    .o_value      (o_bit_field_1_0)
  );
  rggen_default_register #(
    .ADDRESS_WIDTH  (7),
    .START_ADDRESS  (7'h08),
    .END_ADDRESS    (7'h0b),
    .DATA_WIDTH     (32),
    .VALID_BITS     (32'h00010001),
    .READABLE_BITS  (32'h00010001)
  ) u_register_2 (
    .register_if  (register_if[2]),
    .o_select     ()
  );
  rggen_bit_field_ro #(
    .MSB  (16),
    .LSB  (16)
  ) u_bit_field_2_0 (
    .register_if  (register_if[2]),
    .i_value      (i_bit_field_2_0)
  );
  rggen_bit_field_rw #(
    .MSB            (0),
    .LSB            (0),
    .INITIAL_VALUE  (1'h0)
  ) u_bit_field_2_1 (
    .clk          (clk),
    .rst_n        (rst_n),
    .register_if  (register_if[2]),
    .o_value      (o_bit_field_2_1)
  );
endmodule
