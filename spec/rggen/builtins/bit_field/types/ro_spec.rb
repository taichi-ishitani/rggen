require_relative '../../spec_helper'

describe 'bit_fields/type/ro' do
  include_context 'bit field type common'
  include_context 'configuration common'
  include_context 'rtl common'
  include_context 'ral common'

  before(:all) do
    enable :global, [:data_width, :address_width, :unfold_sv_interface_port]
    enable :register_block, [:name, :byte_size]
    enable :register_block, [:clock_reset, :host_if]
    enable :register_block, :host_if, :apb
    enable :register, [:name, :offset_address, :array, :type]
    enable :register, :type, :indirect
    enable :register, :rtl_top
    enable :bit_field, [:name, :bit_assignment, :type, :reference]
    enable :bit_field, :type, :ro

    @factory  = build_register_map_factory
  end

  before(:all) do
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
      it ":roを返す" do
        bit_fields  = build_bit_fields([
          [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[0]", "ro", nil]
        ])
        expect(bit_fields[0].type).to be :ro
      end
    end

    it "アクセス属性はread-only" do
      bit_fields  = build_bit_fields([
        [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[0]", "ro", nil]
      ])
      expect(bit_fields[0]).to match_access(:read_only)
    end

    it "任意のビット幅を持つビットフィールドで使用できる" do
      expect {
        build_bit_fields([
          [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[0]"   , "ro", nil],
          [nil, "register_1", "0x04", nil, nil, "bit_field_1_0", "[1:0]" , "ro", nil],
          [nil, "register_2", "0x08", nil, nil, "bit_field_2_0", "[3:0]" , "ro", nil],
          [nil, "register_3", "0x0C", nil, nil, "bit_field_3_0", "[7:0]" , "ro", nil],
          [nil, "register_4", "0x10", nil, nil, "bit_field_4_0", "[15:0]", "ro", nil],
          [nil, "register_5", "0x14", nil, nil, "bit_field_5_0", "[31:0]", "ro", nil]
        ])
      }.not_to raise_error
    end

    it "参照ビットフィールドの指定に有無にかかわらず使用できる" do
      expect {
        build_bit_fields([
          [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[0]"   , "ro", nil            ],
          [nil, "register_1", "0x04", nil, nil, "bit_field_1_0", "[1:0]" , "ro", "bit_field_0_0"]
        ])
      }.not_to raise_error
    end
  end

  describe "rtl" do
    before(:all) do
      register_map  = create_register_map(
        @configuration,
        "block_0" => [
          [nil, nil, "block_0"                                                                                                      ],
          [nil, nil, 256                                                                                                            ],
          [nil, nil, nil                                                                                                            ],
          [nil, nil, nil                                                                                                            ],
          [nil, "register_0", "0x00-0x07", "[2]"   , nil                                     , "bit_field_0_0", "[31:0]" , "ro", nil],
          [nil, "register_1", "0x08"     , nil     , nil                                     , "bit_field_1_0", "[31:16]", "ro", nil],
          [nil, nil         , nil        , nil     , nil                                     , "bit_field_1_1", "[0]"    , "ro", nil],
          [nil, "register_2", "0x0C"     , "[4, 2]", "indirect: bit_field_1_0, bit_field_1_1", "bit_field_2_0", "[31:0]" , "ro", nil]
        ]
      )
      @rtl  = build_rtl_factory.create(@configuration, register_map).bit_fields
    end

    let(:rtl) do
      @rtl
    end

    it "入力ポートvalue_inを持つ" do
      expect(rtl[0]).to have_input(:register_block, :value_in, name: "i_bit_field_0_0", data_type: :logic, width: 32, dimensions: [2])
      expect(rtl[1]).to have_input(:register_block, :value_in, name: "i_bit_field_1_0", data_type: :logic, width: 16)
      expect(rtl[2]).to have_input(:register_block, :value_in, name: "i_bit_field_1_1", data_type: :logic, width: 1 )
      expect(rtl[3]).to have_input(:register_block, :value_in, name: "i_bit_field_2_0", data_type: :logic, width: 32, dimensions: [4, 2])
    end

    describe "#generate_code" do
      let(:expected_code_0) do
        <<'CODE'
rggen_bit_field_ro #(
  .WIDTH  (32)
) u_bit_field (
  .bit_field_if (bit_field_sub_if),
  .i_value      (i_bit_field_0_0[g_i])
);
CODE
      end

      let(:expected_code_1) do
        <<'CODE'
rggen_bit_field_ro #(
  .WIDTH  (16)
) u_bit_field (
  .bit_field_if (bit_field_sub_if),
  .i_value      (i_bit_field_1_0)
);
CODE
      end

      let(:expected_code_2) do
        <<'CODE'
rggen_bit_field_ro #(
  .WIDTH  (1)
) u_bit_field (
  .bit_field_if (bit_field_sub_if),
  .i_value      (i_bit_field_1_1)
);
CODE
      end

      let(:expected_code_3) do
        <<'CODE'
rggen_bit_field_ro #(
  .WIDTH  (32)
) u_bit_field (
  .bit_field_if (bit_field_sub_if),
  .i_value      (i_bit_field_2_0[g_i][g_j])
CODE
      end

      it "ROビットフィールドモジュールをインスタンスするコードを生成する" do
        expect(rtl[0]).to generate_code(:bit_field, :top_down, expected_code_0)
        expect(rtl[1]).to generate_code(:bit_field, :top_down, expected_code_1)
        expect(rtl[2]).to generate_code(:bit_field, :top_down, expected_code_2)
        expect(rtl[3]).to generate_code(:bit_field, :top_down, expected_code_3)
      end
    end
  end

  describe "ral" do
    before(:all) do
      register_map  = create_register_map(
        @configuration,
        "block_0" => [
          [nil, nil, "block_0"                                                      ],
          [nil, nil, 256                                                            ],
          [nil, nil, nil                                                            ],
          [nil, nil, nil                                                            ],
          [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[31:0]", "ro", nil],
          [nil, "register_1", "0x04", nil, nil, "bit_field_1_0", "[1]"   , "ro", nil],
          [nil, nil         , nil   , nil, nil, "bit_field_1_1", "[0]"   , "ro", nil]
        ]
      )
      @ral  = build_ral_factory.create(@configuration, register_map).bit_fields
    end

    let(:ral) do
      @ral
    end

    describe "#hdl_path" do
      it "ROビットフィールド特有の階層パスを返す" do
        expect(ral[0].hdl_path).to eq "g_bit_field_0_0.u_bit_field.i_value"
        expect(ral[1].hdl_path).to eq "g_bit_field_1_0.u_bit_field.i_value"
        expect(ral[2].hdl_path).to eq "g_bit_field_1_1.u_bit_field.i_value"
      end
    end
  end
end
