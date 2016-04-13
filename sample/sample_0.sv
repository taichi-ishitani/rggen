module sample_0 (
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
  output [15:0] o_bit_field_0_1,
  output [31:0] o_bit_field_1_0,
  input i_bit_field_2_0,
  output o_bit_field_2_1,
  input [31:0] i_bit_field_3_0,
  input [15:0] i_bit_field_4_0[4],
  output [15:0] o_bit_field_4_1[4],
  input [15:0] i_bit_field_5_0[2][4],
  output [15:0] o_bit_field_5_1[2][4]
);
  logic command_valid;
  logic write;
  logic read;
  logic [7:0] address;
  logic [31:0] write_data;
  logic [31:0] write_mask;
  logic response_ready;
  logic [31:0] read_data;
  logic [1:0] status;
  logic [15:0] register_select;
  logic [31:0] register_read_data[16];
  logic [15:0] bit_field_0_0_value;
  logic [15:0] bit_field_0_1_value;
  logic [31:0] bit_field_1_0_value;
  logic bit_field_2_0_value;
  logic bit_field_2_1_value;
  logic [31:0] bit_field_3_0_value;
  logic [15:0] bit_field_4_0_value[4];
  logic [15:0] bit_field_4_1_value[4];
  logic [32:0] register_5_shadow_index[2][4];
  logic [15:0] bit_field_5_0_value[2][4];
  logic [15:0] bit_field_5_1_value[2][4];
  rggen_host_if_apb #(
    .DATA_WIDTH           (32),
    .HOST_ADDRESS_WIDTH   (16),
    .LOCAL_ADDRESS_WIDTH  (8)
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
    .TOTAL_REGISTERS  (16)
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
    .ADDRESS_WIDTH      (6),
    .START_ADDRESS      (6'h00),
    .END_ADDRESS        (6'h00),
    .USE_SHADOW_INDEX   (0),
    .SHADOW_INDEX_WIDTH (1),
    .SHADOW_INDEX_VALUE (1'h0)
  ) u_register_0_address_decoder (
    .i_read         (read),
    .i_write        (write),
    .i_address      (address[7:2]),
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
  assign o_bit_field_0_1 = bit_field_0_1_value;
  rggen_bit_field_rw #(
    .WIDTH          (16),
    .INITIAL_VALUE  (16'h0000)
  ) u_bit_field_0_1 (
    .clk              (clk),
    .rst_n            (rst_n),
    .i_command_valid  (command_valid),
    .i_select         (register_select[0]),
    .i_write          (write),
    .i_write_data     (write_data[15:0]),
    .i_write_mask     (write_mask[15:0]),
    .o_value          (bit_field_0_1_value)
  );
  rggen_address_decoder #(
    .READABLE           (1),
    .WRITABLE           (1),
    .ADDRESS_WIDTH      (6),
    .START_ADDRESS      (6'h01),
    .END_ADDRESS        (6'h01),
    .USE_SHADOW_INDEX   (0),
    .SHADOW_INDEX_WIDTH (1),
    .SHADOW_INDEX_VALUE (1'h0)
  ) u_register_1_address_decoder (
    .i_read         (read),
    .i_write        (write),
    .i_address      (address[7:2]),
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
    .ADDRESS_WIDTH      (6),
    .START_ADDRESS      (6'h02),
    .END_ADDRESS        (6'h02),
    .USE_SHADOW_INDEX   (0),
    .SHADOW_INDEX_WIDTH (1),
    .SHADOW_INDEX_VALUE (1'h0)
  ) u_register_2_address_decoder (
    .i_read         (read),
    .i_write        (write),
    .i_address      (address[7:2]),
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
  rggen_address_decoder #(
    .READABLE           (1),
    .WRITABLE           (0),
    .ADDRESS_WIDTH      (6),
    .START_ADDRESS      (6'h03),
    .END_ADDRESS        (6'h03),
    .USE_SHADOW_INDEX   (0),
    .SHADOW_INDEX_WIDTH (1),
    .SHADOW_INDEX_VALUE (1'h0)
  ) u_register_3_address_decoder (
    .i_read         (read),
    .i_write        (write),
    .i_address      (address[7:2]),
    .i_shadow_index (1'h0),
    .o_select       (register_select[3])
  );
  assign register_read_data[3] = {bit_field_3_0_value};
  assign bit_field_3_0_value = i_bit_field_3_0;
  for (genvar g_i = 0;g_i < 4;g_i++) begin : gen_register_4_0
    rggen_address_decoder #(
      .READABLE           (1),
      .WRITABLE           (1),
      .ADDRESS_WIDTH      (6),
      .START_ADDRESS      (6'h04 + g_i),
      .END_ADDRESS        (6'h04 + g_i),
      .USE_SHADOW_INDEX   (0),
      .SHADOW_INDEX_WIDTH (1),
      .SHADOW_INDEX_VALUE (1'h0)
    ) u_register_4_address_decoder (
      .i_read         (read),
      .i_write        (write),
      .i_address      (address[7:2]),
      .i_shadow_index (1'h0),
      .o_select       (register_select[4+g_i])
    );
    assign register_read_data[4+g_i] = {bit_field_4_0_value[g_i], bit_field_4_1_value[g_i]};
    assign bit_field_4_0_value[g_i] = i_bit_field_4_0[g_i];
    assign o_bit_field_4_1[g_i] = bit_field_4_1_value[g_i];
    rggen_bit_field_rw #(
      .WIDTH          (16),
      .INITIAL_VALUE  (16'h0000)
    ) u_bit_field_4_1 (
      .clk              (clk),
      .rst_n            (rst_n),
      .i_command_valid  (command_valid),
      .i_select         (register_select[4+g_i]),
      .i_write          (write),
      .i_write_data     (write_data[15:0]),
      .i_write_mask     (write_mask[15:0]),
      .o_value          (bit_field_4_1_value[g_i])
    );
  end
  for (genvar g_i = 0;g_i < 2;g_i++) begin : gen_register_5_0
    for (genvar g_j = 0;g_j < 4;g_j++) begin : gen_register_5_1
      assign register_5_shadow_index[g_i][g_j] = {bit_field_2_1_value, bit_field_0_0_value, bit_field_0_1_value};
      rggen_address_decoder #(
        .READABLE           (1),
        .WRITABLE           (1),
        .ADDRESS_WIDTH      (6),
        .START_ADDRESS      (6'h08),
        .END_ADDRESS        (6'h08),
        .USE_SHADOW_INDEX   (1),
        .SHADOW_INDEX_WIDTH (33),
        .SHADOW_INDEX_VALUE ({1'h1, g_i[15:0], g_j[15:0]})
      ) u_register_5_address_decoder (
        .i_read         (read),
        .i_write        (write),
        .i_address      (address[7:2]),
        .i_shadow_index (register_5_shadow_index[g_i][g_j]),
        .o_select       (register_select[8+4*g_i+g_j])
      );
      assign register_read_data[8+4*g_i+g_j] = {bit_field_5_0_value[g_i][g_j], bit_field_5_1_value[g_i][g_j]};
      assign bit_field_5_0_value[g_i][g_j] = i_bit_field_5_0[g_i][g_j];
      assign o_bit_field_5_1[g_i][g_j] = bit_field_5_1_value[g_i][g_j];
      rggen_bit_field_rw #(
        .WIDTH          (16),
        .INITIAL_VALUE  (16'h0000)
      ) u_bit_field_5_1 (
        .clk              (clk),
        .rst_n            (rst_n),
        .i_command_valid  (command_valid),
        .i_select         (register_select[8+4*g_i+g_j]),
        .i_write          (write),
        .i_write_data     (write_data[15:0]),
        .i_write_mask     (write_mask[15:0]),
        .o_value          (bit_field_5_1_value[g_i][g_j])
      );
    end
  end
endmodule
