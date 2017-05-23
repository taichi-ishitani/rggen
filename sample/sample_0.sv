module sample_0 (
  input clk,
  input rst_n,
  rggen_apb_if.slave apb_if,
  output o_irq,
  output [15:0] o_bit_field_0_0,
  output [15:0] o_bit_field_0_1,
  output [31:0] o_bit_field_1_0,
  input i_bit_field_2_0,
  output o_bit_field_2_1,
  input [31:0] i_bit_field_3_0,
  input [15:0] i_bit_field_4_0[4],
  output [15:0] o_bit_field_4_1[4],
  input [15:0] i_bit_field_5_0[2][4],
  output [15:0] o_bit_field_5_1[2][4],
  input i_bit_field_6_0_set,
  input i_bit_field_6_1_set,
  output o_bit_field_7_0,
  input i_bit_field_7_0_clear,
  output o_bit_field_7_1,
  input i_bit_field_7_1_clear,
  output [15:0] o_bit_field_8_0,
  output [15:0] o_bit_field_8_1,
  rggen_bus_if.master register_9_bus_if
);
  rggen_register_if #(8, 32) register_if[20]();
  logic [1:0] ier;
  logic [1:0] isr;
  `define rggen_connect_bit_field_if(RIF, FIF, MSB, LSB) \
    assign  FIF.read_access         = RIF.read_access; \
    assign  FIF.write_access        = RIF.write_access; \
    assign  FIF.write_data          = RIF.write_data[MSB:LSB]; \
    assign  FIF.write_mask          = RIF.write_mask[MSB:LSB]; \
    assign  RIF.value[MSB:LSB]      = FIF.value; \
    assign  RIF.read_data[MSB:LSB]  = FIF.read_data;
  rggen_host_if_apb #(
    .LOCAL_ADDRESS_WIDTH  (8),
    .DATA_WIDTH           (32),
    .TOTAL_REGISTERS      (20)
  ) u_host_if (
    .clk          (clk),
    .rst_n        (rst_n),
    .apb_if       (apb_if),
    .register_if  (register_if)
  );
  assign ier = {register_if[2].value[0], register_if[2].value[0]};
  assign isr = {register_if[16].value[8], register_if[16].value[0]};
  rggen_irq_controller #(
    .TOTAL_INTERRUPTS (2)
  ) u_irq_controller (
    .clk    (clk),
    .rst_n  (rst_n),
    .i_ier  (ier),
    .i_isr  (isr),
    .o_irq  (o_irq)
  );
  generate if (1) begin : g_register_0
    rggen_bit_field_if #(32) bit_field_if();
    rggen_bit_field_if #(16) bit_field_0_0_if();
    rggen_bit_field_if #(16) bit_field_0_1_if();
    rggen_default_register #(
      .ADDRESS_WIDTH  (8),
      .START_ADDRESS  (8'h00),
      .END_ADDRESS    (8'h03),
      .DATA_WIDTH     (32),
      .VALID_BITS     (32'hffffffff)
    ) u_register_0 (
      .register_if  (register_if[0]),
      .bit_field_if (bit_field_if)
    );
    `rggen_connect_bit_field_if(bit_field_if, bit_field_0_0_if, 31, 16)
    rggen_bit_field_rw #(
      .WIDTH          (16),
      .INITIAL_VALUE  (16'h0000)
    ) u_bit_field_0_0 (
      .clk          (clk),
      .rst_n        (rst_n),
      .bit_field_if (bit_field_0_0_if),
      .o_value      (o_bit_field_0_0)
    );
    `rggen_connect_bit_field_if(bit_field_if, bit_field_0_1_if, 15, 0)
    rggen_bit_field_rw #(
      .WIDTH          (16),
      .INITIAL_VALUE  (16'h0000)
    ) u_bit_field_0_1 (
      .clk          (clk),
      .rst_n        (rst_n),
      .bit_field_if (bit_field_0_1_if),
      .o_value      (o_bit_field_0_1)
    );
  end endgenerate
  generate if (1) begin : g_register_1
    rggen_bit_field_if #(32) bit_field_if();
    rggen_bit_field_if #(32) bit_field_1_0_if();
    rggen_default_register #(
      .ADDRESS_WIDTH  (8),
      .START_ADDRESS  (8'h04),
      .END_ADDRESS    (8'h07),
      .DATA_WIDTH     (32),
      .VALID_BITS     (32'hffffffff)
    ) u_register_1 (
      .register_if  (register_if[1]),
      .bit_field_if (bit_field_if)
    );
    `rggen_connect_bit_field_if(bit_field_if, bit_field_1_0_if, 31, 0)
    rggen_bit_field_rw #(
      .WIDTH          (32),
      .INITIAL_VALUE  (32'h00000000)
    ) u_bit_field_1_0 (
      .clk          (clk),
      .rst_n        (rst_n),
      .bit_field_if (bit_field_1_0_if),
      .o_value      (o_bit_field_1_0)
    );
  end endgenerate
  generate if (1) begin : g_register_2
    rggen_bit_field_if #(32) bit_field_if();
    rggen_bit_field_if #(1) bit_field_2_0_if();
    rggen_bit_field_if #(1) bit_field_2_1_if();
    rggen_default_register #(
      .ADDRESS_WIDTH  (8),
      .START_ADDRESS  (8'h08),
      .END_ADDRESS    (8'h0b),
      .DATA_WIDTH     (32),
      .VALID_BITS     (32'h00010001)
    ) u_register_2 (
      .register_if  (register_if[2]),
      .bit_field_if (bit_field_if)
    );
    `rggen_connect_bit_field_if(bit_field_if, bit_field_2_0_if, 16, 16)
    rggen_bit_field_ro #(
      .WIDTH  (1)
    ) u_bit_field_2_0 (
      .bit_field_if (bit_field_2_0_if),
      .i_value      (i_bit_field_2_0)
    );
    `rggen_connect_bit_field_if(bit_field_if, bit_field_2_1_if, 0, 0)
    rggen_bit_field_rw #(
      .WIDTH          (1),
      .INITIAL_VALUE  (1'h0)
    ) u_bit_field_2_1 (
      .clk          (clk),
      .rst_n        (rst_n),
      .bit_field_if (bit_field_2_1_if),
      .o_value      (o_bit_field_2_1)
    );
  end endgenerate
  generate if (1) begin : g_register_3
    rggen_bit_field_if #(32) bit_field_if();
    rggen_bit_field_if #(32) bit_field_3_0_if();
    rggen_default_register #(
      .ADDRESS_WIDTH  (8),
      .START_ADDRESS  (8'h0c),
      .END_ADDRESS    (8'h0f),
      .DATA_WIDTH     (32),
      .VALID_BITS     (32'hffffffff)
    ) u_register_3 (
      .register_if  (register_if[3]),
      .bit_field_if (bit_field_if)
    );
    `rggen_connect_bit_field_if(bit_field_if, bit_field_3_0_if, 31, 0)
    rggen_bit_field_ro #(
      .WIDTH  (32)
    ) u_bit_field_3_0 (
      .bit_field_if (bit_field_3_0_if),
      .i_value      (i_bit_field_3_0)
    );
  end endgenerate
  generate if (1) begin : g_register_4
    genvar g_i;
    for (g_i = 0;g_i < 4;++g_i) begin : g
      rggen_bit_field_if #(32) bit_field_if();
      rggen_bit_field_if #(16) bit_field_4_0_if();
      rggen_bit_field_if #(16) bit_field_4_1_if();
      rggen_default_register #(
        .ADDRESS_WIDTH  (8),
        .START_ADDRESS  (8'h10 + 8'h04 * g_i),
        .END_ADDRESS    (8'h13 + 8'h04 * g_i),
        .DATA_WIDTH     (32),
        .VALID_BITS     (32'hffffffff)
      ) u_register_4 (
        .register_if  (register_if[4+g_i]),
        .bit_field_if (bit_field_if)
      );
      `rggen_connect_bit_field_if(bit_field_if, bit_field_4_0_if, 31, 16)
      rggen_bit_field_ro #(
        .WIDTH  (16)
      ) u_bit_field_4_0 (
        .bit_field_if (bit_field_4_0_if),
        .i_value      (i_bit_field_4_0[g_i])
      );
      `rggen_connect_bit_field_if(bit_field_if, bit_field_4_1_if, 15, 0)
      rggen_bit_field_rw #(
        .WIDTH          (16),
        .INITIAL_VALUE  (16'h0000)
      ) u_bit_field_4_1 (
        .clk          (clk),
        .rst_n        (rst_n),
        .bit_field_if (bit_field_4_1_if),
        .o_value      (o_bit_field_4_1[g_i])
      );
    end
  end endgenerate
  generate if (1) begin : g_register_5
    genvar g_i;
    for (g_i = 0;g_i < 2;++g_i) begin : g
      genvar g_j;
      for (g_j = 0;g_j < 4;++g_j) begin : g
        rggen_bit_field_if #(32) bit_field_if();
        logic [32:0] indirect_index;
        rggen_bit_field_if #(16) bit_field_5_0_if();
        rggen_bit_field_if #(16) bit_field_5_1_if();
        assign indirect_index = {register_if[2].value[0], register_if[0].value[31:16], register_if[0].value[15:0]};
        rggen_indirect_register #(
          .ADDRESS_WIDTH  (8),
          .START_ADDRESS  (8'h20),
          .END_ADDRESS    (8'h23),
          .INDEX_WIDTH    (33),
          .INDEX_VALUE    ({1'h1, g_i[15:0], g_j[15:0]}),
          .DATA_WIDTH     (32),
          .VALID_BITS     (32'hffffffff)
        ) u_register_5 (
          .register_if  (register_if[8+4*g_i+g_j]),
          .bit_field_if (bit_field_if),
          .i_index      (indirect_index)
        );
        `rggen_connect_bit_field_if(bit_field_if, bit_field_5_0_if, 31, 16)
        rggen_bit_field_ro #(
          .WIDTH  (16)
        ) u_bit_field_5_0 (
          .bit_field_if (bit_field_5_0_if),
          .i_value      (i_bit_field_5_0[g_i][g_j])
        );
        `rggen_connect_bit_field_if(bit_field_if, bit_field_5_1_if, 15, 0)
        rggen_bit_field_rw #(
          .WIDTH          (16),
          .INITIAL_VALUE  (16'h0000)
        ) u_bit_field_5_1 (
          .clk          (clk),
          .rst_n        (rst_n),
          .bit_field_if (bit_field_5_1_if),
          .o_value      (o_bit_field_5_1[g_i][g_j])
        );
      end
    end
  end endgenerate
  generate if (1) begin : g_register_6
    rggen_bit_field_if #(32) bit_field_if();
    rggen_bit_field_if #(1) bit_field_6_0_if();
    rggen_bit_field_if #(1) bit_field_6_1_if();
    rggen_default_register #(
      .ADDRESS_WIDTH  (8),
      .START_ADDRESS  (8'h24),
      .END_ADDRESS    (8'h27),
      .DATA_WIDTH     (32),
      .VALID_BITS     (32'h00000101)
    ) u_register_6 (
      .register_if  (register_if[16]),
      .bit_field_if (bit_field_if)
    );
    `rggen_connect_bit_field_if(bit_field_if, bit_field_6_0_if, 8, 8)
    rggen_bit_field_w01s_w01c #(
      .MODE             (rggen_rtl_pkg::RGGEN_CLEAR_MODE),
      .SET_CLEAR_VALUE  (0),
      .WIDTH            (1),
      .INITIAL_VALUE    (1'h0)
    ) u_bit_field_6_0 (
      .clk            (clk),
      .rst_n          (rst_n),
      .i_set_or_clear (i_bit_field_6_0_set),
      .bit_field_if   (bit_field_6_0_if),
      .o_value        ()
    );
    `rggen_connect_bit_field_if(bit_field_if, bit_field_6_1_if, 0, 0)
    rggen_bit_field_w01s_w01c #(
      .MODE             (rggen_rtl_pkg::RGGEN_CLEAR_MODE),
      .SET_CLEAR_VALUE  (1),
      .WIDTH            (1),
      .INITIAL_VALUE    (1'h0)
    ) u_bit_field_6_1 (
      .clk            (clk),
      .rst_n          (rst_n),
      .i_set_or_clear (i_bit_field_6_1_set),
      .bit_field_if   (bit_field_6_1_if),
      .o_value        ()
    );
  end endgenerate
  generate if (1) begin : g_register_7
    rggen_bit_field_if #(32) bit_field_if();
    rggen_bit_field_if #(1) bit_field_7_0_if();
    rggen_bit_field_if #(1) bit_field_7_1_if();
    rggen_default_register #(
      .ADDRESS_WIDTH  (8),
      .START_ADDRESS  (8'h28),
      .END_ADDRESS    (8'h2b),
      .DATA_WIDTH     (32),
      .VALID_BITS     (32'h00000101)
    ) u_register_7 (
      .register_if  (register_if[17]),
      .bit_field_if (bit_field_if)
    );
    `rggen_connect_bit_field_if(bit_field_if, bit_field_7_0_if, 8, 8)
    rggen_bit_field_w01s_w01c #(
      .MODE             (rggen_rtl_pkg::RGGEN_SET_MODE),
      .SET_CLEAR_VALUE  (0),
      .WIDTH            (1),
      .INITIAL_VALUE    (1'h0)
    ) u_bit_field_7_0 (
      .clk            (clk),
      .rst_n          (rst_n),
      .i_set_or_clear (i_bit_field_7_0_clear),
      .bit_field_if   (bit_field_7_0_if),
      .o_value        (o_bit_field_7_0)
    );
    `rggen_connect_bit_field_if(bit_field_if, bit_field_7_1_if, 0, 0)
    rggen_bit_field_w01s_w01c #(
      .MODE             (rggen_rtl_pkg::RGGEN_SET_MODE),
      .SET_CLEAR_VALUE  (1),
      .WIDTH            (1),
      .INITIAL_VALUE    (1'h0)
    ) u_bit_field_7_1 (
      .clk            (clk),
      .rst_n          (rst_n),
      .i_set_or_clear (i_bit_field_7_1_clear),
      .bit_field_if   (bit_field_7_1_if),
      .o_value        (o_bit_field_7_1)
    );
  end endgenerate
  generate if (1) begin : g_register_8
    rggen_bit_field_if #(32) bit_field_if();
    rggen_bit_field_if #(16) bit_field_8_0_if();
    rggen_bit_field_if #(16) bit_field_8_1_if();
    rggen_default_register #(
      .ADDRESS_WIDTH  (8),
      .START_ADDRESS  (8'h2c),
      .END_ADDRESS    (8'h2f),
      .DATA_WIDTH     (32),
      .VALID_BITS     (32'hffffffff)
    ) u_register_8 (
      .register_if  (register_if[18]),
      .bit_field_if (bit_field_if)
    );
    `rggen_connect_bit_field_if(bit_field_if, bit_field_8_0_if, 31, 16)
    rggen_bit_field_rwl_rwe #(
      .MODE           (rggen_rtl_pkg::RGGEN_LOCK_MODE),
      .WIDTH          (16),
      .INITIAL_VALUE  (16'h0000)
    ) u_bit_field_8_0 (
      .clk              (clk),
      .rst_n            (rst_n),
      .i_lock_or_enable (register_if[2].value[0]),
      .bit_field_if     (bit_field_8_0_if),
      .o_value          (o_bit_field_8_0)
    );
    `rggen_connect_bit_field_if(bit_field_if, bit_field_8_1_if, 15, 0)
    rggen_bit_field_rwl_rwe #(
      .MODE           (rggen_rtl_pkg::RGGEN_ENABLE_MODE),
      .WIDTH          (16),
      .INITIAL_VALUE  (16'h0000)
    ) u_bit_field_8_1 (
      .clk              (clk),
      .rst_n            (rst_n),
      .i_lock_or_enable (register_if[2].value[0]),
      .bit_field_if     (bit_field_8_1_if),
      .o_value          (o_bit_field_8_1)
    );
  end endgenerate
  generate if (1) begin : g_register_9
    rggen_external_register #(
      .ADDRESS_WIDTH  (8),
      .START_ADDRESS  (8'h80),
      .END_ADDRESS    (8'hff),
      .DATA_WIDTH     (32)
    ) u_register_9 (
      .clk          (clk),
      .rst_n        (rst_n),
      .register_if  (register_if[19]),
      .bus_if       (register_9_bus_if)
    );
  end endgenerate
  `undef rggen_connect_bit_field_if
endmodule
