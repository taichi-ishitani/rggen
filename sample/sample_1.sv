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
  rggen_bit_field_if #(32, 2, '{31, 15}, '{16, 0}) register_0_bit_field_if();
  rggen_bit_field_if #(32, 1, '{31}, '{0}) register_1_bit_field_if();
  rggen_bit_field_if #(32, 2, '{16, 0}, '{16, 0}) register_2_bit_field_if();
  rggen_host_if_apb #(
    .LOCAL_ADDRESS_WIDTH  (7),
    .DATA_WIDTH           (32),
    .TOTAL_REGISTERS      (3)
  ) u_host_if (
    .clk          (clk),
    .rst_n        (rst_n),
    .apb_if       (apb_if),
    .register_if  (register_if)
  );
  rggen_default_register #(
    .ADDRESS_WIDTH  (7),
    .START_ADDRESS  (7'h00),
    .END_ADDRESS    (7'h03),
    .DATA_WIDTH     (32)
  ) u_register_0 (
    .register_if  (register_if[0]),
    .bit_field_if (register_0_bit_field_if)
  );
  rggen_bit_field_rw #(
    .WIDTH          (16),
    .INITIAL_VALUE  (16'h0000)
  ) u_bit_field_0_0 (
    .clk          (clk),
    .rst_n        (rst_n),
    .bit_field_if (register_0_bit_field_if.bit_fields[0].slave),
    .o_value      (o_bit_field_0_0)
  );
  rggen_bit_field_ro #(
    .WIDTH  (16)
  ) u_bit_field_0_1 (
    .bit_field_if (register_0_bit_field_if.bit_fields[1].slave),
    .i_value      (i_bit_field_0_1)
  );
  rggen_default_register #(
    .ADDRESS_WIDTH  (7),
    .START_ADDRESS  (7'h04),
    .END_ADDRESS    (7'h07),
    .DATA_WIDTH     (32)
  ) u_register_1 (
    .register_if  (register_if[1]),
    .bit_field_if (register_1_bit_field_if)
  );
  rggen_bit_field_rw #(
    .WIDTH          (32),
    .INITIAL_VALUE  (32'h00000000)
  ) u_bit_field_1_0 (
    .clk          (clk),
    .rst_n        (rst_n),
    .bit_field_if (register_1_bit_field_if.bit_fields[0].slave),
    .o_value      (o_bit_field_1_0)
  );
  rggen_default_register #(
    .ADDRESS_WIDTH  (7),
    .START_ADDRESS  (7'h08),
    .END_ADDRESS    (7'h0b),
    .DATA_WIDTH     (32)
  ) u_register_2 (
    .register_if  (register_if[2]),
    .bit_field_if (register_2_bit_field_if)
  );
  rggen_bit_field_ro #(
    .WIDTH  (1)
  ) u_bit_field_2_0 (
    .bit_field_if (register_2_bit_field_if.bit_fields[0].slave),
    .i_value      (i_bit_field_2_0)
  );
  rggen_bit_field_rw #(
    .WIDTH          (1),
    .INITIAL_VALUE  (1'h0)
  ) u_bit_field_2_1 (
    .clk          (clk),
    .rst_n        (rst_n),
    .bit_field_if (register_2_bit_field_if.bit_fields[1].slave),
    .o_value      (o_bit_field_2_1)
  );
endmodule
