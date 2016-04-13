module sample_1 (
  input clk,
  input rst_n,
  input [15:0] i_paddr,
  input [2:0] i_pprot,
  input i_psel,
  input i_penable,
  input i_pwrite,
  input [31:0] i_pwdata,
  input [3:0] i_pstrb,
  output o_pready,
  output [31:0] o_prdata,
  output o_pslverr,
  output [15:0] o_bit_field_0_0,
  input [15:0] i_bit_field_0_1,
  output [31:0] o_bit_field_1_0,
  input i_bit_field_2_0,
  output o_bit_field_2_1
);
  logic command_valid;
  logic write;
  logic read;
  logic [6:0] address;
  logic [31:0] write_data;
  logic [31:0] write_mask;
  logic response_ready;
  logic [31:0] read_data;
  logic [1:0] status;
  logic [2:0] register_select;
  logic [31:0] register_read_data[3];
  logic [15:0] bit_field_0_0_value;
  logic [15:0] bit_field_0_1_value;
  logic [31:0] bit_field_1_0_value;
  logic bit_field_2_0_value;
  logic bit_field_2_1_value;
  rggen_host_if_apb #(
    .DATA_WIDTH           (32),
    .HOST_ADDRESS_WIDTH   (16),
    .LOCAL_ADDRESS_WIDTH  (7)
  ) u_host_if (
    .clk              (clk),
    .rst_n            (rst_n),
    .i_paddr          (i_paddr),
    .i_pprot          (i_pprot),
    .i_psel           (i_psel),
    .i_penable        (i_penable),
    .i_pwrite         (i_pwrite),
    .i_pwdata         (i_pwdata),
    .i_pstrb          (i_pstrb),
    .o_pready         (o_pready),
    .o_prdata         (o_prdata),
    .o_pslverr        (o_pslverr),
    .o_command_valid  (command_valid),
    .o_write          (write),
    .o_read           (read),
    .o_address        (address),
    .o_write_data     (write_data),
    .o_write_mask     (write_mask),
    .i_response_ready (response_ready),
    .i_read_data      (read_data),
    .i_status         (status)
  );
  rggen_response_mux #(
    .DATA_WIDTH       (32),
    .TOTAL_REGISTERS  (3)
  ) u_response_mux (
    .clk                  (clk),
    .rst_n                (rst_n),
    .i_command_valid      (command_valid),
    .i_read               (read),
    .o_response_ready     (response_ready),
    .o_read_data          (read_data),
    .o_status             (status),
    .i_register_select    (register_select),
    .i_register_read_data (register_read_data)
  );
  rggen_address_decoder #(
    .READABLE           (1),
    .WRITABLE           (1),
    .ADDRESS_WIDTH      (5),
    .START_ADDRESS      (5'h00),
    .END_ADDRESS        (5'h00),
    .USE_SHADOW_INDEX   (0),
    .SHADOW_INDEX_WIDTH (1),
    .SHADOW_INDEX_VALUE (1'h0)
  ) u_register_0_address_decoder (
    .i_read         (read),
    .i_write        (write),
    .i_address      (address[6:2]),
    .i_shadow_index (1'h0),
    .o_select       (register_select[0])
  );
  assign register_read_data[0] = {bit_field_0_0_value, bit_field_0_1_value};
  assign o_bit_field_0_0 = bit_field_0_0_value;
  rggen_bit_field_rw #(
    .WIDTH          (16),
    .INITIAL_VALUE  (16'h0000)
  ) u_bit_field_0_0 (
    .clk              (clk),
    .rst_n            (rst_n),
    .i_command_valid  (command_valid),
    .i_select         (register_select[0]),
    .i_write          (write),
    .i_write_data     (write_data[31:16]),
    .i_write_mask     (write_mask[31:16]),
    .o_value          (bit_field_0_0_value)
  );
  assign bit_field_0_1_value = i_bit_field_0_1;
  rggen_address_decoder #(
    .READABLE           (1),
    .WRITABLE           (1),
    .ADDRESS_WIDTH      (5),
    .START_ADDRESS      (5'h01),
    .END_ADDRESS        (5'h01),
    .USE_SHADOW_INDEX   (0),
    .SHADOW_INDEX_WIDTH (1),
    .SHADOW_INDEX_VALUE (1'h0)
  ) u_register_1_address_decoder (
    .i_read         (read),
    .i_write        (write),
    .i_address      (address[6:2]),
    .i_shadow_index (1'h0),
    .o_select       (register_select[1])
  );
  assign register_read_data[1] = {bit_field_1_0_value};
  assign o_bit_field_1_0 = bit_field_1_0_value;
  rggen_bit_field_rw #(
    .WIDTH          (32),
    .INITIAL_VALUE  (32'h00000000)
  ) u_bit_field_1_0 (
    .clk              (clk),
    .rst_n            (rst_n),
    .i_command_valid  (command_valid),
    .i_select         (register_select[1]),
    .i_write          (write),
    .i_write_data     (write_data[31:0]),
    .i_write_mask     (write_mask[31:0]),
    .o_value          (bit_field_1_0_value)
  );
  rggen_address_decoder #(
    .READABLE           (1),
    .WRITABLE           (1),
    .ADDRESS_WIDTH      (5),
    .START_ADDRESS      (5'h02),
    .END_ADDRESS        (5'h02),
    .USE_SHADOW_INDEX   (0),
    .SHADOW_INDEX_WIDTH (1),
    .SHADOW_INDEX_VALUE (1'h0)
  ) u_register_2_address_decoder (
    .i_read         (read),
    .i_write        (write),
    .i_address      (address[6:2]),
    .i_shadow_index (1'h0),
    .o_select       (register_select[2])
  );
  assign register_read_data[2] = {15'h0000, bit_field_2_0_value, 15'h0000, bit_field_2_1_value};
  assign bit_field_2_0_value = i_bit_field_2_0;
  assign o_bit_field_2_1 = bit_field_2_1_value;
  rggen_bit_field_rw #(
    .WIDTH          (1),
    .INITIAL_VALUE  (1'h0)
  ) u_bit_field_2_1 (
    .clk              (clk),
    .rst_n            (rst_n),
    .i_command_valid  (command_valid),
    .i_select         (register_select[2]),
    .i_write          (write),
    .i_write_data     (write_data[0]),
    .i_write_mask     (write_mask[0]),
    .o_value          (bit_field_2_1_value)
  );
endmodule
