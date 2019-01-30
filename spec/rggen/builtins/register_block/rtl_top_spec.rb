require_relative '../spec_helper'

describe "register_block/rtl_top" do
  include_context 'configuration common'
  include_context 'register_map common'
  include_context 'rtl common'

  before(:all) do
    enable :global, [:data_width, :address_width, :array_port_format, :unfold_sv_interface_port]
    enable :register_block, [:name, :byte_size]
    enable :register_block, [:rtl_top, :clock_reset, :host_if]
    enable :register_block, :host_if, :apb
    enable :register, [:name, :offset_address, :array, :type]
    enable :register, :type, [:external, :indirect]
    enable :register, :rtl_top
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field, :type, [:rw, :ro, :w0c, :w1c]
    enable :bit_field, :rtl_top

    configuration = create_configuration(address_width: 16)
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil         , "block_0"                                                                                                                               ],
        [nil, nil         , 256                                                                                                                                     ],
        [                                                                                                                                                           ],
        [                                                                                                                                                           ],
        [nil, "register_0", "0x00"     , nil     , nil                                                     , "bit_field_0_0", "[16]"   , "rw" , 0  , nil            ],
        [nil, nil         , nil        , nil     , nil                                                     , "bit_field_0_1", "[0]"    , "ro" , 0  , nil            ],
        [nil, "register_1", "0x04"     , nil     , nil                                                     , "bit_field_1_0", "[31:16]", "ro" , 0  , nil            ],
        [nil, nil         , nil        , nil     , nil                                                     , "bit_field_1_1", "[15:0]" , "rw" , 0  , nil            ],
        [nil, "register_2", "0x08-0x0F", "[2]"   , nil                                                     , "bit_field_2_0", "[31:16]", "ro" , 0  , nil            ],
        [nil, nil         , nil        , nil     , nil                                                     , "bit_field_2_1", "[15:0]" , "rw" , 0  , nil            ],
        [nil, "register_3", "0x10"     , "[2,4]", "indirect: bit_field_0_0:1, bit_field_1_0, bit_field_1_1", "bit_field_3_0", "[31:16]", "ro" , 0  , nil            ],
        [nil, nil         , nil        , nil    , nil                                                      , "bit_field_3_1", "[15:0]" , "rw" , 0  , nil            ],
        [nil, "register_4", "0x14"     , nil    , nil                                                      , "bit_field_4_0", "[8]"    , "w0c", 0  , "bit_field_0_0"],
        [nil, nil         , nil        , nil    , nil                                                      , "bit_field_4_1", "[0]"    , "w1c", 0  , "bit_field_0_0"],
        [nil, "register_5", "0x20-0x2F", nil    , :external                                                , nil            , nil      , nil  , nil, nil            ]
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
    let(:expected_code) do
      <<'CODE'
module block_0 (
  input logic clk,
  input logic rst_n,
  rggen_apb_if.slave apb_if,
  output logic o_bit_field_0_0,
  input logic i_bit_field_0_1,
  input logic [15:0] i_bit_field_1_0,
  output logic [15:0] o_bit_field_1_1,
  input logic [15:0] i_bit_field_2_0[2],
  output logic [15:0] o_bit_field_2_1[2],
  input logic [15:0] i_bit_field_3_0[2][4],
  output logic [15:0] o_bit_field_3_1[2][4],
  input logic i_bit_field_4_0_set,
  input logic i_bit_field_4_1_set,
  rggen_bus_if.master register_5_bus_if
);
  `include "rggen_rtl_macros.svh"
  rggen_register_if #(8, 32) register_if[14]();
  rggen_host_if_apb #(
    .LOCAL_ADDRESS_WIDTH  (8),
    .DATA_WIDTH           (32),
    .TOTAL_REGISTERS      (14)
  ) u_host_if (
    .clk          (clk),
    .rst_n        (rst_n),
    .apb_if       (apb_if),
    .register_if  (register_if)
  );
  generate if (1) begin : g_register_0
    rggen_bit_field_if #(32) bit_field_if();
    rggen_default_register #(
      .ADDRESS_WIDTH  (8),
      .START_ADDRESS  (8'h00),
      .END_ADDRESS    (8'h03),
      .DATA_WIDTH     (32),
      .VALID_BITS     (32'h00010001)
    ) u_register (
      .register_if  (register_if[0]),
      .bit_field_if (bit_field_if)
    );
    if (1) begin : g_bit_field_0_0
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 16, 16)
      rggen_bit_field_rw #(
        .WIDTH          (1),
        .INITIAL_VALUE  (1'h0)
      ) u_bit_field (
        .clk          (clk),
        .rst_n        (rst_n),
        .bit_field_if (bit_field_sub_if),
        .o_value      (o_bit_field_0_0)
      );
    end
    if (1) begin : g_bit_field_0_1
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 0)
      rggen_bit_field_ro #(
        .WIDTH  (1)
      ) u_bit_field (
        .bit_field_if (bit_field_sub_if),
        .i_value      (i_bit_field_0_1)
      );
    end
  end endgenerate
  generate if (1) begin : g_register_1
    rggen_bit_field_if #(32) bit_field_if();
    rggen_default_register #(
      .ADDRESS_WIDTH  (8),
      .START_ADDRESS  (8'h04),
      .END_ADDRESS    (8'h07),
      .DATA_WIDTH     (32),
      .VALID_BITS     (32'hffffffff)
    ) u_register (
      .register_if  (register_if[1]),
      .bit_field_if (bit_field_if)
    );
    if (1) begin : g_bit_field_1_0
      rggen_bit_field_if #(16) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 31, 16)
      rggen_bit_field_ro #(
        .WIDTH  (16)
      ) u_bit_field (
        .bit_field_if (bit_field_sub_if),
        .i_value      (i_bit_field_1_0)
      );
    end
    if (1) begin : g_bit_field_1_1
      rggen_bit_field_if #(16) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 15, 0)
      rggen_bit_field_rw #(
        .WIDTH          (16),
        .INITIAL_VALUE  (16'h0000)
      ) u_bit_field (
        .clk          (clk),
        .rst_n        (rst_n),
        .bit_field_if (bit_field_sub_if),
        .o_value      (o_bit_field_1_1)
      );
    end
  end endgenerate
  generate if (1) begin : g_register_2
    genvar g_i;
    for (g_i = 0;g_i < 2;++g_i) begin : g
      rggen_bit_field_if #(32) bit_field_if();
      rggen_default_register #(
        .ADDRESS_WIDTH  (8),
        .START_ADDRESS  (8'h08 + 8'h04 * g_i),
        .END_ADDRESS    (8'h0b + 8'h04 * g_i),
        .DATA_WIDTH     (32),
        .VALID_BITS     (32'hffffffff)
      ) u_register (
        .register_if  (register_if[2+g_i]),
        .bit_field_if (bit_field_if)
      );
      if (1) begin : g_bit_field_2_0
        rggen_bit_field_if #(16) bit_field_sub_if();
        `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 31, 16)
        rggen_bit_field_ro #(
          .WIDTH  (16)
        ) u_bit_field (
          .bit_field_if (bit_field_sub_if),
          .i_value      (i_bit_field_2_0[g_i])
        );
      end
      if (1) begin : g_bit_field_2_1
        rggen_bit_field_if #(16) bit_field_sub_if();
        `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 15, 0)
        rggen_bit_field_rw #(
          .WIDTH          (16),
          .INITIAL_VALUE  (16'h0000)
        ) u_bit_field (
          .clk          (clk),
          .rst_n        (rst_n),
          .bit_field_if (bit_field_sub_if),
          .o_value      (o_bit_field_2_1[g_i])
        );
      end
    end
  end endgenerate
  generate if (1) begin : g_register_3
    genvar g_i;
    for (g_i = 0;g_i < 2;++g_i) begin : g
      genvar g_j;
      for (g_j = 0;g_j < 4;++g_j) begin : g
        rggen_bit_field_if #(32) bit_field_if();
        logic [32:0] indirect_index;
        assign indirect_index = {register_if[0].value[16], register_if[1].value[31:16], register_if[1].value[15:0]};
        rggen_indirect_register #(
          .ADDRESS_WIDTH  (8),
          .START_ADDRESS  (8'h10),
          .END_ADDRESS    (8'h13),
          .INDEX_WIDTH    (33),
          .INDEX_VALUE    ({1'h1, g_i[15:0], g_j[15:0]}),
          .DATA_WIDTH     (32),
          .VALID_BITS     (32'hffffffff)
        ) u_register (
          .register_if  (register_if[4+4*g_i+g_j]),
          .bit_field_if (bit_field_if),
          .i_index      (indirect_index)
        );
        if (1) begin : g_bit_field_3_0
          rggen_bit_field_if #(16) bit_field_sub_if();
          `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 31, 16)
          rggen_bit_field_ro #(
            .WIDTH  (16)
          ) u_bit_field (
            .bit_field_if (bit_field_sub_if),
            .i_value      (i_bit_field_3_0[g_i][g_j])
          );
        end
        if (1) begin : g_bit_field_3_1
          rggen_bit_field_if #(16) bit_field_sub_if();
          `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 15, 0)
          rggen_bit_field_rw #(
            .WIDTH          (16),
            .INITIAL_VALUE  (16'h0000)
          ) u_bit_field (
            .clk          (clk),
            .rst_n        (rst_n),
            .bit_field_if (bit_field_sub_if),
            .o_value      (o_bit_field_3_1[g_i][g_j])
          );
        end
      end
    end
  end endgenerate
  generate if (1) begin : g_register_4
    rggen_bit_field_if #(32) bit_field_if();
    rggen_default_register #(
      .ADDRESS_WIDTH  (8),
      .START_ADDRESS  (8'h14),
      .END_ADDRESS    (8'h17),
      .DATA_WIDTH     (32),
      .VALID_BITS     (32'h00000101)
    ) u_register (
      .register_if  (register_if[12]),
      .bit_field_if (bit_field_if)
    );
    if (1) begin : g_bit_field_4_0
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 8, 8)
      rggen_bit_field_w01s_w01c #(
        .MODE             (rggen_rtl_pkg::RGGEN_CLEAR_MODE),
        .SET_CLEAR_VALUE  (0),
        .WIDTH            (1),
        .INITIAL_VALUE    (1'h0)
      ) u_bit_field (
        .clk            (clk),
        .rst_n          (rst_n),
        .i_set_or_clear (i_bit_field_4_0_set),
        .bit_field_if   (bit_field_sub_if),
        .o_value        ()
      );
    end
    if (1) begin : g_bit_field_4_1
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 0)
      rggen_bit_field_w01s_w01c #(
        .MODE             (rggen_rtl_pkg::RGGEN_CLEAR_MODE),
        .SET_CLEAR_VALUE  (1),
        .WIDTH            (1),
        .INITIAL_VALUE    (1'h0)
      ) u_bit_field (
        .clk            (clk),
        .rst_n          (rst_n),
        .i_set_or_clear (i_bit_field_4_1_set),
        .bit_field_if   (bit_field_sub_if),
        .o_value        ()
      );
    end
  end endgenerate
  generate if (1) begin : g_register_5
    rggen_external_register #(
      .ADDRESS_WIDTH  (8),
      .START_ADDRESS  (8'h20),
      .END_ADDRESS    (8'h2f),
      .DATA_WIDTH     (32)
    ) u_register (
      .clk          (clk),
      .rst_n        (rst_n),
      .register_if  (register_if[13]),
      .bus_if       (register_5_bus_if)
    );
  end endgenerate
endmodule
CODE
    end

    it "レジスタモジュールのRTLを書き出す" do
      expect { rtl.write_file('.') }.to write_binary_file("./block_0.sv", expected_code)
    end
  end
end
