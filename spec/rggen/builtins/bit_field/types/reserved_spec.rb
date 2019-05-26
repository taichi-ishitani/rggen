require_relative '../../spec_helper'

describe 'bit_fields/type/reserved' do
  include_context 'bit field type common'
  include_context 'configuration common'
  include_context 'rtl common'
  include_context 'ral common'

  before(:all) do
    enable :global, [:data_width, :address_width, :array_port_format,:unfold_sv_interface_port]
    enable :register_block, [:name, :byte_size]
    enable :register_block, [:clock_reset, :host_if]
    enable :register_block, :host_if, :apb
    enable :register, [:name, :offset_address, :array, :type]
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field, :type, [:reserved, :rw]
    @factory  = build_register_map_factory
  end

  before(:all) do
    ConfigurationDummyLoader.load_data({})
    enable :global, :data_width
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
      it ":reservedを返す" do
        bit_fields  = build_bit_fields([
          [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[0]", "reserved", nil, nil]
        ])
        expect(bit_fields[0].type).to be :reserved
      end
    end

    it "アクセス属性はreserved" do
      bit_fields  = build_bit_fields([
        [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[0]", "reserved", nil, nil]
      ])
      expect(bit_fields[0]).to match_access(:reserved)
    end

    it "任意のビット幅を持つビットフィールドで使用できる" do
      expect {
        build_bit_fields([
          [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[0]"   , "reserved", nil, nil],
          [nil, "register_1", "0x04", nil, nil, "bit_field_1_0", "[1:0]" , "reserved", nil, nil],
          [nil, "register_2", "0x08", nil, nil, "bit_field_2_0", "[3:0]" , "reserved", nil, nil],
          [nil, "register_3", "0x0C", nil, nil, "bit_field_3_0", "[7:0]" , "reserved", nil, nil],
          [nil, "register_4", "0x10", nil, nil, "bit_field_4_0", "[15:0]", "reserved", nil, nil],
          [nil, "register_5", "0x14", nil, nil, "bit_field_5_0", "[31:0]", "reserved", nil, nil]
        ])
      }.not_to raise_error
    end

    it "参照ビットフィールドの指定に有無にかかわらず使用できる" do
      expect {
        build_bit_fields([
          [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[0]" , "rw"      , 0  , nil            ],
          [nil, "register_1", "0x04", nil, nil, "bit_field_1_0", "[0]" , "reserved", nil, nil            ],
          [nil, "register_2", "0x08", nil, nil, "bit_field_2_0", "[0]" , "reserved", nil, "bit_field_0_0"]
        ])
      }.not_to raise_error
    end
  end

  describe "rtl" do
    let(:register_map) do
      create_register_map(
        configuration,
        "block_0" => [
          [nil, nil, "block_0"                                                                    ],
          [nil, nil, 256                                                                          ],
          [nil, nil, nil                                                                          ],
          [nil, nil, nil                                                                          ],
          [nil, "register_0", "0x00-0x07", "[2]", nil, "bit_field_0_0", "[31:0]" , "reserved", nil],
          [nil, "register_1", "0x08"     , nil  , nil, "bit_field_1_0", "[31:16]", "reserved", nil],
          [nil, nil         , nil        , nil  , nil, "bit_field_1_1", "[0]"    , "reserved", nil]
        ]
      )
    end

    let(:rtl) do
      build_rtl_factory.create(@configuration, register_map).bit_fields
    end

    describe "#generate_code" do
      let(:array_port_format) { :unpacked }

      let(:expected_code_0) do
        <<'CODE'
rggen_bit_field_ro #(
  .WIDTH  (32)
) u_bit_field (
  .bit_field_if (bit_field_sub_if),
  .i_value      (32'h00000000)
);
CODE
      end

      let(:expected_code_1) do
        <<'CODE'
rggen_bit_field_ro #(
  .WIDTH  (16)
) u_bit_field (
  .bit_field_if (bit_field_sub_if),
  .i_value      (16'h0000)
);
CODE
      end

      let(:expected_code_2) do
        <<'CODE'
rggen_bit_field_ro #(
  .WIDTH  (1)
) u_bit_field (
  .bit_field_if (bit_field_sub_if),
  .i_value      (1'h0)
);
CODE
      end

      it "予約済みビットフィールドとして、ROビットフィールドモジュールをインスタンスするコードを生成する" do
        expect(rtl[0]).to generate_code(:bit_field, :top_down, expected_code_0)
        expect(rtl[1]).to generate_code(:bit_field, :top_down, expected_code_1)
        expect(rtl[2]).to generate_code(:bit_field, :top_down, expected_code_2)
      end
    end
  end

  describe "ral" do
    let(:register_map) do
      set_load_data([
        [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[0]", "reserved", nil, nil]
      ])
      @factory.create(configuration, register_map_file)
    end

    let(:ral) do
      build_ral_factory.create(@configuration, register_map).bit_fields[0]
    end

    describe "#access" do
      it "ROを返す" do
        expect(ral.access).to eq "\"RO\""
      end
    end

    describe "#hdl_path" do
      it "予約済みビットフィールド特有の階層パスを返す" do
        expect(ral.hdl_path).to eq "g_bit_field_0_0.u_bit_field.i_value"
      end
    end
  end
end
