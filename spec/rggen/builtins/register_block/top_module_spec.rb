require_relative '../spec_helper'

describe "register_block/top_module" do
  include_context 'configuration common'
  include_context 'register_map common'
  include_context 'rtl common'

  before(:all) do
    enable :global, [:data_width, :address_width]
    enable :register_block, [:name, :byte_size]
    enable :register_block, [:top_module, :clock_reset, :host_if, :response_mux, :irq_controller]
    enable :register_block, :host_if, :apb
    enable :register, [:name, :offset_address, :array, :shadow, :external, :accessibility]
    enable :register, [:address_decoder, :read_data, :bus_exporter]
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field, :type, [:rw, :ro, :w0c, :w1c]

    configuration = create_configuration(address_width: 16)
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil         , "block_0"                                                                                                                           ],
        [nil, nil         , 256                                                                                                                                 ],
        [                                                                                                                                                       ],
        [                                                                                                                                                       ],
        [nil, "register_0", "0x00"     , nil     , nil                                           , nil , "bit_field_0_0", "[16]"   , "rw" , 0  , nil            ],
        [nil, nil         , nil        , nil     , nil                                           , nil , "bit_field_0_1", "[0]"    , "ro" , 0  , nil            ],
        [nil, "register_1", "0x04"     , nil     , nil                                           , nil , "bit_field_1_0", "[31:16]", "ro" , 0  , nil            ],
        [nil, nil         , nil        , nil     , nil                                           , nil , "bit_field_1_1", "[15:0]" , "rw" , 0  , nil            ],
        [nil, "register_2", "0x08-0x0F", "[2]"   , nil                                           , nil , "bit_field_2_0", "[31:16]", "ro" , 0  , nil            ],
        [nil, nil         , nil        , nil     , nil                                           , nil , "bit_field_2_1", "[15:0]" , "rw" , 0  , nil            ],
        [nil, "register_3", "0x10"     , "[2,4]", "bit_field_0_0:1, bit_field_1_0, bit_field_1_1", nil , "bit_field_3_0", "[31:16]", "ro" , 0  , nil            ],
        [nil, nil         , nil        , nil    , nil                                            , nil , "bit_field_3_1", "[15:0]" , "rw" , 0  , nil            ],
        [nil, "register_4", "0x14"     , nil    , nil                                            , nil , "bit_field_4_0", "[8]"    , "w0c", 0  , "bit_field_0_0"],
        [nil, nil         , nil        , nil    , nil                                            , nil , "bit_field_4_1", "[0]"    , "w1c", 0  , "bit_field_0_0"],
        [nil, "register_5", "0x20-0x2F", nil    , nil                                            , true, nil            , nil      , nil  , nil, nil            ]
      ]
    )

    @rtl  = build_rtl_factory.create(configuration, register_map).register_blocks[0]
  end

  after(:all) do
    clear_enabled_items
  end

  let(:rtl) do
    @rtl
  end

  describe "#write_file" do
    before do
      expect(File).to receive(:write).with("./block_0.sv", expected_code, nil, binmode: true)
    end

    let(:expected_code) do
      <<'CODE'
module block_0 (
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
  output o_irq,
  output o_bit_field_0_0,
  input i_bit_field_0_1,
  input [15:0] i_bit_field_1_0,
  output [15:0] o_bit_field_1_1,
  input [15:0] i_bit_field_2_0[2],
  output [15:0] o_bit_field_2_1[2],
  input [15:0] i_bit_field_3_0[2][4],
  output [15:0] o_bit_field_3_1[2][4],
  input i_bit_field_4_0_set,
  input i_bit_field_4_1_set,
  output o_register_5_valid,
  output o_register_5_write,
  output o_register_5_read,
  output [3:0] o_register_5_address,
  output [3:0] o_register_5_strobe,
  output [31:0] o_register_5_write_data,
  input i_register_5_ready,
  input [1:0] i_register_5_status,
  input [31:0] i_register_5_read_data
);
  logic command_valid;
  logic write;
  logic read;
  logic [7:0] address;
  logic [3:0] strobe;
  logic [31:0] write_data;
  logic [31:0] write_mask;
  logic response_ready;
  logic [31:0] read_data;
  logic [1:0] status;
  logic [13:0] register_select;
  logic [31:0] register_read_data[14];
  logic [0:0] external_register_select;
  logic [0:0] external_register_ready;
  logic [1:0] external_register_status[1];
  logic [1:0] ier;
  logic [1:0] isr;
  logic bit_field_0_0_value;
  logic bit_field_0_1_value;
  logic [15:0] bit_field_1_0_value;
  logic [15:0] bit_field_1_1_value;
  logic [15:0] bit_field_2_0_value[2];
  logic [15:0] bit_field_2_1_value[2];
  logic [32:0] register_3_shadow_index[2][4];
  logic [15:0] bit_field_3_0_value[2][4];
  logic [15:0] bit_field_3_1_value[2][4];
  logic bit_field_4_0_value;
  logic bit_field_4_1_value;
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
    .o_strobe         (strobe),
    .o_write_data     (write_data),
    .o_write_mask     (write_mask),
    .i_response_ready (response_ready),
    .i_read_data      (read_data),
    .i_status         (status)
  );
  rggen_response_mux #(
    .DATA_WIDTH               (32),
    .TOTAL_REGISTERS          (14),
    .TOTAL_EXTERNAL_REGISTERS (1)
  ) u_response_mux (
    .clk                        (clk),
    .rst_n                      (rst_n),
    .i_command_valid            (command_valid),
    .i_read                     (read),
    .o_response_ready           (response_ready),
    .o_read_data                (read_data),
    .o_status                   (status),
    .i_register_select          (register_select),
    .i_register_read_data       (register_read_data),
    .i_external_register_select (external_register_select),
    .i_external_register_ready  (external_register_ready),
    .i_external_register_status (external_register_status)
  );
  assign ier = {bit_field_0_0_value, bit_field_0_0_value};
  assign isr = {bit_field_4_0_value, bit_field_4_1_value};
  rggen_irq_controller #(
    .TOTAL_INTERRUPTS (2)
  ) u_irq_controller (
    .clk    (clk),
    .rst_n  (rst_n),
    .i_ier  (ier),
    .i_isr  (isr),
    .o_irq  (o_irq)
  );
  rggen_address_decoder #(
    .ADDRESS_WIDTH      (6),
    .START_ADDRESS      (6'h00),
    .END_ADDRESS        (6'h00),
    .USE_SHADOW_INDEX   (0),
    .SHADOW_INDEX_WIDTH (1),
    .SHADOW_INDEX_VALUE (1'h0)
  ) u_register_0_address_decoder (
    .i_address      (address[7:2]),
    .i_shadow_index (1'h0),
    .o_select       (register_select[0])
  );
  assign register_read_data[0] = {15'h0000, bit_field_0_0_value, 15'h0000, bit_field_0_1_value};
  assign o_bit_field_0_0 = bit_field_0_0_value;
  rggen_bit_field_rw #(
    .WIDTH          (1),
    .INITIAL_VALUE  (1'h0)
  ) u_bit_field_0_0 (
    .clk              (clk),
    .rst_n            (rst_n),
    .i_command_valid  (command_valid),
    .i_select         (register_select[0]),
    .i_write          (write),
    .i_write_data     (write_data[16]),
    .i_write_mask     (write_mask[16]),
    .o_value          (bit_field_0_0_value)
  );
  rggen_bit_field_ro #(
    .WIDTH  (1)
  ) u_bit_field_0_1 (
    .i_value  (i_bit_field_0_1),
    .o_value  (bit_field_0_1_value)
  );
  rggen_address_decoder #(
    .ADDRESS_WIDTH      (6),
    .START_ADDRESS      (6'h01),
    .END_ADDRESS        (6'h01),
    .USE_SHADOW_INDEX   (0),
    .SHADOW_INDEX_WIDTH (1),
    .SHADOW_INDEX_VALUE (1'h0)
  ) u_register_1_address_decoder (
    .i_address      (address[7:2]),
    .i_shadow_index (1'h0),
    .o_select       (register_select[1])
  );
  assign register_read_data[1] = {bit_field_1_0_value, bit_field_1_1_value};
  rggen_bit_field_ro #(
    .WIDTH  (16)
  ) u_bit_field_1_0 (
    .i_value  (i_bit_field_1_0),
    .o_value  (bit_field_1_0_value)
  );
  assign o_bit_field_1_1 = bit_field_1_1_value;
  rggen_bit_field_rw #(
    .WIDTH          (16),
    .INITIAL_VALUE  (16'h0000)
  ) u_bit_field_1_1 (
    .clk              (clk),
    .rst_n            (rst_n),
    .i_command_valid  (command_valid),
    .i_select         (register_select[1]),
    .i_write          (write),
    .i_write_data     (write_data[15:0]),
    .i_write_mask     (write_mask[15:0]),
    .o_value          (bit_field_1_1_value)
  );
  generate if (1) begin : g_register_2
    genvar g_i;
    for (g_i = 0;g_i < 2;g_i++) begin : g
      rggen_address_decoder #(
        .ADDRESS_WIDTH      (6),
        .START_ADDRESS      (6'h02 + g_i),
        .END_ADDRESS        (6'h02 + g_i),
        .USE_SHADOW_INDEX   (0),
        .SHADOW_INDEX_WIDTH (1),
        .SHADOW_INDEX_VALUE (1'h0)
      ) u_register_2_address_decoder (
        .i_address      (address[7:2]),
        .i_shadow_index (1'h0),
        .o_select       (register_select[2+g_i])
      );
      assign register_read_data[2+g_i] = {bit_field_2_0_value[g_i], bit_field_2_1_value[g_i]};
      rggen_bit_field_ro #(
        .WIDTH  (16)
      ) u_bit_field_2_0 (
        .i_value  (i_bit_field_2_0[g_i]),
        .o_value  (bit_field_2_0_value[g_i])
      );
      assign o_bit_field_2_1[g_i] = bit_field_2_1_value[g_i];
      rggen_bit_field_rw #(
        .WIDTH          (16),
        .INITIAL_VALUE  (16'h0000)
      ) u_bit_field_2_1 (
        .clk              (clk),
        .rst_n            (rst_n),
        .i_command_valid  (command_valid),
        .i_select         (register_select[2+g_i]),
        .i_write          (write),
        .i_write_data     (write_data[15:0]),
        .i_write_mask     (write_mask[15:0]),
        .o_value          (bit_field_2_1_value[g_i])
      );
    end
  end endgenerate
  generate if (1) begin : g_register_3
    genvar g_i, g_j;
    for (g_i = 0;g_i < 2;g_i++) begin : g
      for (g_j = 0;g_j < 4;g_j++) begin : g
        assign register_3_shadow_index[g_i][g_j] = {bit_field_0_0_value, bit_field_1_0_value, bit_field_1_1_value};
        rggen_address_decoder #(
          .ADDRESS_WIDTH      (6),
          .START_ADDRESS      (6'h04),
          .END_ADDRESS        (6'h04),
          .USE_SHADOW_INDEX   (1),
          .SHADOW_INDEX_WIDTH (33),
          .SHADOW_INDEX_VALUE ({1'h1, g_i[15:0], g_j[15:0]})
        ) u_register_3_address_decoder (
          .i_address      (address[7:2]),
          .i_shadow_index (register_3_shadow_index[g_i][g_j]),
          .o_select       (register_select[4+4*g_i+g_j])
        );
        assign register_read_data[4+4*g_i+g_j] = {bit_field_3_0_value[g_i][g_j], bit_field_3_1_value[g_i][g_j]};
        rggen_bit_field_ro #(
          .WIDTH  (16)
        ) u_bit_field_3_0 (
          .i_value  (i_bit_field_3_0[g_i][g_j]),
          .o_value  (bit_field_3_0_value[g_i][g_j])
        );
        assign o_bit_field_3_1[g_i][g_j] = bit_field_3_1_value[g_i][g_j];
        rggen_bit_field_rw #(
          .WIDTH          (16),
          .INITIAL_VALUE  (16'h0000)
        ) u_bit_field_3_1 (
          .clk              (clk),
          .rst_n            (rst_n),
          .i_command_valid  (command_valid),
          .i_select         (register_select[4+4*g_i+g_j]),
          .i_write          (write),
          .i_write_data     (write_data[15:0]),
          .i_write_mask     (write_mask[15:0]),
          .o_value          (bit_field_3_1_value[g_i][g_j])
        );
      end
    end
  end endgenerate
  rggen_address_decoder #(
    .ADDRESS_WIDTH      (6),
    .START_ADDRESS      (6'h05),
    .END_ADDRESS        (6'h05),
    .USE_SHADOW_INDEX   (0),
    .SHADOW_INDEX_WIDTH (1),
    .SHADOW_INDEX_VALUE (1'h0)
  ) u_register_4_address_decoder (
    .i_address      (address[7:2]),
    .i_shadow_index (1'h0),
    .o_select       (register_select[12])
  );
  assign register_read_data[12] = {23'h000000, bit_field_4_0_value, 7'h00, bit_field_4_1_value};
  rggen_bit_field_w01s_w01c #(
    .WIDTH            (1),
    .INITIAL_VALUE    (1'h0),
    .SET_MODE         (0),
    .SET_CLEAR_VALUE  (0)
  ) u_bit_field_4_0 (
    .clk              (clk),
    .rst_n            (rst_n),
    .i_set_or_clear   (i_bit_field_4_0_set),
    .i_command_valid  (command_valid),
    .i_select         (register_select[12]),
    .i_write          (write),
    .i_write_data     (write_data[8]),
    .i_write_mask     (write_mask[8]),
    .o_value          (bit_field_4_0_value)
  );
  rggen_bit_field_w01s_w01c #(
    .WIDTH            (1),
    .INITIAL_VALUE    (1'h0),
    .SET_MODE         (0),
    .SET_CLEAR_VALUE  (1)
  ) u_bit_field_4_1 (
    .clk              (clk),
    .rst_n            (rst_n),
    .i_set_or_clear   (i_bit_field_4_1_set),
    .i_command_valid  (command_valid),
    .i_select         (register_select[12]),
    .i_write          (write),
    .i_write_data     (write_data[0]),
    .i_write_mask     (write_mask[0]),
    .o_value          (bit_field_4_1_value)
  );
  rggen_address_decoder #(
    .ADDRESS_WIDTH      (6),
    .START_ADDRESS      (6'h08),
    .END_ADDRESS        (6'h0b),
    .USE_SHADOW_INDEX   (0),
    .SHADOW_INDEX_WIDTH (1),
    .SHADOW_INDEX_VALUE (1'h0)
  ) u_register_5_address_decoder (
    .i_address      (address[7:2]),
    .i_shadow_index (1'h0),
    .o_select       (register_select[13])
  );
  assign external_register_select[0] = register_select[13];
  rggen_bus_exporter #(
    .DATA_WIDTH             (32),
    .LOCAL_ADDRESS_WIDTH    (8),
    .EXTERNAL_ADDRESS_WIDTH (4),
    .START_ADDRESS          (8'h20)
  ) u_register_5_bus_exporter (
    .clk          (clk),
    .rst_n        (rst_n),
    .i_valid      (command_valid),
    .i_select     (register_select[13]),
    .i_write      (write),
    .i_read       (read),
    .i_address    (address),
    .i_strobe     (strobe),
    .i_write_data (write_data),
    .o_ready      (external_register_ready[0]),
    .o_read_data  (register_read_data[13]),
    .o_status     (external_register_status[0]),
    .o_valid      (o_register_5_valid),
    .o_write      (o_register_5_write),
    .o_read       (o_register_5_read),
    .o_address    (o_register_5_address),
    .o_strobe     (o_register_5_strobe),
    .o_write_data (o_register_5_write_data),
    .i_ready      (i_register_5_ready),
    .i_read_data  (i_register_5_read_data),
    .i_status     (i_register_5_status)
  );
endmodule
CODE
    end

    it "レジスタモジュールのRTLを書き出す" do
      rtl.write_file('.')
    end
  end
end
