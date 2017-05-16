require_relative '../../spec_helper'

describe 'bit_fields/type/w0s_w1s' do
  include_context 'bit field type common'
  include_context 'configuration common'
  include_context 'rtl common'

  before(:all) do
    enable :register_block, [:name, :byte_size]
    enable :register_block, [:clock_reset, :host_if]
    enable :register_block, :host_if, :apb
    enable :register, [:name, :offset_address, :array, :type]
    enable :register, :type, :indirect
    enable :register, :rtl_top
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field, :type, [:w0s, :w1s, :rw]

    @factory  = build_register_map_factory
  end

  before(:all) do
    enable :global, [:data_width, :address_width]
    ConfigurationDummyLoader.load_data({})
    @configuration  = build_configuration_factory.create(configuration_file)
  end

  after(:all) do
    clear_enabled_items
  end

  let(:configuration) do
    @configuration
  end

  describe "register_map" do
    describe "#type" do
      it ":w0s/:w1sを返す" do
        bit_fields  = build_bit_fields([
          [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[0]", "w0s", '0', nil],
          [nil, nil         , nil   , nil, nil, "bit_field_0_1", "[1]", "w1s", '0', nil]
        ])
        expect(bit_fields[0].type).to be :w0s
        expect(bit_fields[1].type).to be :w1s
      end
    end

    it "アクセス属性はread-write" do
      bit_fields  = build_bit_fields([
        [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[0]", "w0s", '0', nil],
        [nil, nil         , nil   , nil, nil, "bit_field_0_1", "[1]", "w1s", '0', nil]
      ])
      expect(bit_fields[0]).to match_access :read_write
      expect(bit_fields[1]).to match_access :read_write
    end

    it "任意のビット幅を持つビットフィールドで使用できる" do
      expect {
        build_bit_fields([
          [nil, "register_0" , "0x00", nil, nil, "bit_field_0_0" , "[0]"   , "w0s", '0', nil],
          [nil, "register_1" , "0x04", nil, nil, "bit_field_1_0" , "[1:0]" , "w0s", '0', nil],
          [nil, "register_2" , "0x08", nil, nil, "bit_field_2_0" , "[3:0]" , "w0s", '0', nil],
          [nil, "register_3" , "0x0C", nil, nil, "bit_field_3_0" , "[7:0]" , "w0s", '0', nil],
          [nil, "register_4" , "0x10", nil, nil, "bit_field_4_0" , "[15:0]", "w0s", '0', nil],
          [nil, "register_5" , "0x14", nil, nil, "bit_field_5_0" , "[31:0]", "w0s", '0', nil],
          [nil, "register_6" , "0x20", nil, nil, "bit_field_6_0" , "[0]"   , "w1s", '0', nil],
          [nil, "register_7" , "0x24", nil, nil, "bit_field_7_0" , "[1:0]" , "w1s", '0', nil],
          [nil, "register_8" , "0x28", nil, nil, "bit_field_8_0" , "[3:0]" , "w1s", '0', nil],
          [nil, "register_9" , "0x2C", nil, nil, "bit_field_9_0" , "[7:0]" , "w1s", '0', nil],
          [nil, "register_10", "0x30", nil, nil, "bit_field_10_0", "[15:0]", "w1s", '0', nil],
          [nil, "register_11", "0x34", nil, nil, "bit_field_11_0", "[31:0]", "w1s", '0', nil]
        ])
      }.not_to raise_error
    end

    it "初期値を必要とする" do
      expect {
        build_bit_fields([
          [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[0]", "w0s", nil, nil]
        ])
      }.to raise_error RgGen::RegisterMapError
      expect {
        build_bit_fields([
          [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[0]", "w1s", nil, nil]
        ])
      }.to raise_error RgGen::RegisterMapError
    end

    it "参照ビットフィールドの有無に関わらず使用できる" do
      expect {
        build_bit_fields([
          [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[4]", "w0s", '0', nil            ],
          [nil, nil         , nil   , nil, nil, "bit_field_0_1", "[0]", "w0s", '0', "bit_field_2_0"],
          [nil, "register_1", "0x04", nil, nil, "bit_field_1_0", "[4]", "w1s", '0', nil            ],
          [nil, nil         , nil   , nil, nil, "bit_field_1_1", "[0]", "w1s", '0', "bit_field_2_0"],
          [nil, "register_2", "0x08", nil, nil, "bit_field_2_0", "[0]", "rw" , '0', nil            ]
        ])
      }
    end
  end

  describe "rtl" do
    before(:all) do
      register_map  = create_register_map(
        @configuration,
        "block_0" => [
          [nil, nil         , "block_0"                                                                                                        ],
          [nil, nil         , 256                                                                                                              ],
          [nil, nil         , nil                                                                                                              ],
          [nil, nil         , nil                                                                                                              ],
          [nil, "register_0", "0x00"     , nil     , nil                                     , "bit_field_0_0", "[31:16]", "w0s", "0x0123", nil],
          [nil, nil         , nil        , nil     , nil                                     , "bit_field_0_1", "[0]"    , "w0s", "0x0"   , nil],
          [nil, "register_1", "0x04-0x0B", "[2]"   , nil                                     , "bit_field_1_0", "[0]"    , "w0s", "0x0"   , nil],
          [nil, "register_2", "0x0C"     , "[2, 2]", "indirect: bit_field_6_0, bit_field_6_1", "bit_field_2_0", "[0]"    , "w0s", "0x0"   , nil],
          [nil, "register_3", "0x10"     , nil     , nil                                     , "bit_field_3_0", "[31:16]", "w1s", "0x4567", nil],
          [nil, nil         , nil        , nil     , nil                                     , "bit_field_3_1", "[0]"    , "w1s", "0x0"   , nil],
          [nil, "register_4", "0x14-0x1B", "[2]"   , nil                                     , "bit_field_4_0", "[0]"    , "w1s", "0x0"   , nil],
          [nil, "register_5", "0x1C"     , "[2, 2]", "indirect: bit_field_6_0, bit_field_6_1", "bit_field_5_0", "[0]"    , "w1s", "0x0"   , nil],
          [nil, "register_6", "0x20"     , nil     , nil                                     , "bit_field_6_0", "[3:2]"  , "rw" , "0x0"   , nil],
          [nil, nil         , nil        , nil     , nil                                     , "bit_field_6_1", "[1:0]"  , "rw" , "0x0"   , nil]
        ]
      )
      @rtl  = build_rtl_factory.create(@configuration, register_map).bit_fields
    end

    let(:rtl) do
      @rtl
    end

    it "出力ポートvalue_outを持つ" do
      expect(rtl[0]).to have_output :register_block, :value_out, name: "o_bit_field_0_0", width: 16
      expect(rtl[1]).to have_output :register_block, :value_out, name: "o_bit_field_0_1", width: 1
      expect(rtl[2]).to have_output :register_block, :value_out, name: "o_bit_field_1_0", width: 1 , dimensions: [2]
      expect(rtl[3]).to have_output :register_block, :value_out, name: "o_bit_field_2_0", width: 1 , dimensions: [2, 2]
      expect(rtl[4]).to have_output :register_block, :value_out, name: "o_bit_field_3_0", width: 16
      expect(rtl[5]).to have_output :register_block, :value_out, name: "o_bit_field_3_1", width: 1
      expect(rtl[6]).to have_output :register_block, :value_out, name: "o_bit_field_4_0", width: 1 , dimensions: [2]
      expect(rtl[7]).to have_output :register_block, :value_out, name: "o_bit_field_5_0", width: 1 , dimensions: [2, 2]
    end

    it "入力ポートclearを持つ" do
      expect(rtl[0]).to have_input :register_block, :clear, name: "i_bit_field_0_0_clear", width: 16
      expect(rtl[1]).to have_input :register_block, :clear, name: "i_bit_field_0_1_clear", width: 1
      expect(rtl[2]).to have_input :register_block, :clear, name: "i_bit_field_1_0_clear", width: 1 , dimensions: [2]
      expect(rtl[3]).to have_input :register_block, :clear, name: "i_bit_field_2_0_clear", width: 1 , dimensions: [2, 2]
      expect(rtl[4]).to have_input :register_block, :clear, name: "i_bit_field_3_0_clear", width: 16
      expect(rtl[5]).to have_input :register_block, :clear, name: "i_bit_field_3_1_clear", width: 1
      expect(rtl[6]).to have_input :register_block, :clear, name: "i_bit_field_4_0_clear", width: 1 , dimensions: [2]
      expect(rtl[7]).to have_input :register_block, :clear, name: "i_bit_field_5_0_clear", width: 1 , dimensions: [2, 2]
    end

    describe "#generate_code" do
      let(:expected_code_0) do
        <<'CODE'
rggen_bit_field_w01s_w01c #(
  .MODE             (rggen_rtl_pkg::RGGEN_SET_MODE),
  .SET_CLEAR_VALUE  (0),
  .WIDTH            (16),
  .INITIAL_VALUE    (16'h0123)
) u_bit_field_0_0 (
  .clk            (clk),
  .rst_n          (rst_n),
  .i_set_or_clear (i_bit_field_0_0_clear),
  .bit_field_if   (bit_field_if[0]),
  .o_value        (o_bit_field_0_0)
);
CODE
      end

      let(:expected_code_1) do
        <<'CODE'
rggen_bit_field_w01s_w01c #(
  .MODE             (rggen_rtl_pkg::RGGEN_SET_MODE),
  .SET_CLEAR_VALUE  (0),
  .WIDTH            (1),
  .INITIAL_VALUE    (1'h0)
) u_bit_field_0_1 (
  .clk            (clk),
  .rst_n          (rst_n),
  .i_set_or_clear (i_bit_field_0_1_clear),
  .bit_field_if   (bit_field_if[1]),
  .o_value        (o_bit_field_0_1)
);
CODE
      end

      let(:expected_code_2) do
        <<'CODE'
rggen_bit_field_w01s_w01c #(
  .MODE             (rggen_rtl_pkg::RGGEN_SET_MODE),
  .SET_CLEAR_VALUE  (0),
  .WIDTH            (1),
  .INITIAL_VALUE    (1'h0)
) u_bit_field_1_0 (
  .clk            (clk),
  .rst_n          (rst_n),
  .i_set_or_clear (i_bit_field_1_0_clear[g_i]),
  .bit_field_if   (bit_field_if[0]),
  .o_value        (o_bit_field_1_0[g_i])
);
CODE
      end

      let(:expected_code_3) do
        <<'CODE'
rggen_bit_field_w01s_w01c #(
  .MODE             (rggen_rtl_pkg::RGGEN_SET_MODE),
  .SET_CLEAR_VALUE  (0),
  .WIDTH            (1),
  .INITIAL_VALUE    (1'h0)
) u_bit_field_2_0 (
  .clk            (clk),
  .rst_n          (rst_n),
  .i_set_or_clear (i_bit_field_2_0_clear[g_i][g_j]),
  .bit_field_if   (bit_field_if[0]),
  .o_value        (o_bit_field_2_0[g_i][g_j])
);
CODE
      end

      let(:expected_code_4) do
        <<'CODE'
rggen_bit_field_w01s_w01c #(
  .MODE             (rggen_rtl_pkg::RGGEN_SET_MODE),
  .SET_CLEAR_VALUE  (1),
  .WIDTH            (16),
  .INITIAL_VALUE    (16'h4567)
) u_bit_field_3_0 (
  .clk            (clk),
  .rst_n          (rst_n),
  .i_set_or_clear (i_bit_field_3_0_clear),
  .bit_field_if   (bit_field_if[0]),
  .o_value        (o_bit_field_3_0)
);
CODE
      end

      let(:expected_code_5) do
        <<'CODE'
rggen_bit_field_w01s_w01c #(
  .MODE             (rggen_rtl_pkg::RGGEN_SET_MODE),
  .SET_CLEAR_VALUE  (1),
  .WIDTH            (1),
  .INITIAL_VALUE    (1'h0)
) u_bit_field_3_1 (
  .clk            (clk),
  .rst_n          (rst_n),
  .i_set_or_clear (i_bit_field_3_1_clear),
  .bit_field_if   (bit_field_if[1]),
  .o_value        (o_bit_field_3_1)
);
CODE
      end

      let(:expected_code_6) do
        <<'CODE'
rggen_bit_field_w01s_w01c #(
  .MODE             (rggen_rtl_pkg::RGGEN_SET_MODE),
  .SET_CLEAR_VALUE  (1),
  .WIDTH            (1),
  .INITIAL_VALUE    (1'h0)
) u_bit_field_4_0 (
  .clk            (clk),
  .rst_n          (rst_n),
  .i_set_or_clear (i_bit_field_4_0_clear[g_i]),
  .bit_field_if   (bit_field_if[0]),
  .o_value        (o_bit_field_4_0[g_i])
);
CODE
      end

      let(:expected_code_7) do
        <<'CODE'
rggen_bit_field_w01s_w01c #(
  .MODE             (rggen_rtl_pkg::RGGEN_SET_MODE),
  .SET_CLEAR_VALUE  (1),
  .WIDTH            (1),
  .INITIAL_VALUE    (1'h0)
) u_bit_field_5_0 (
  .clk            (clk),
  .rst_n          (rst_n),
  .i_set_or_clear (i_bit_field_5_0_clear[g_i][g_j]),
  .bit_field_if   (bit_field_if[0]),
  .o_value        (o_bit_field_5_0[g_i][g_j])
);
CODE
      end

      it "W0S/W1Sビットフィールドモジュールをインスタンスするコードを生成する" do
        expect(rtl[0]).to generate_code :register, :top_down, expected_code_0
        expect(rtl[1]).to generate_code :register, :top_down, expected_code_1
        expect(rtl[2]).to generate_code :register, :top_down, expected_code_2
        expect(rtl[3]).to generate_code :register, :top_down, expected_code_3
        expect(rtl[4]).to generate_code :register, :top_down, expected_code_4
        expect(rtl[5]).to generate_code :register, :top_down, expected_code_5
        expect(rtl[6]).to generate_code :register, :top_down, expected_code_6
        expect(rtl[7]).to generate_code :register, :top_down, expected_code_7
      end
    end
  end
end
