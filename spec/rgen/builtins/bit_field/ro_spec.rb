require_relative '../spec_helper'

describe 'bit_fields/type/ro' do
  include_context 'bit field type common'
  include_context 'configuration common'
  include_context 'rtl common'

  before(:all) do
    RGen.enable(:global, [:data_width, :address_width])
    RGen.enable(:register_block, [:name, :byte_size])
    RGen.enable(:register_block, [:clock_reset, :host_if, :response_mux])
    RGen.enable(:register_block, :host_if, :apb)
    RGen.enable(:register, [:name, :offset_address, :array])
    RGen.enable(:bit_field, [:name, :bit_assignment, :type, :reference])
    RGen.enable(:bit_field, :type, :ro)

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

  describe "#register_map" do
    describe "#type" do
      it ":roを返す" do
        bit_fields  = build_bit_fields([
          [nil, "register_0", "0x00", nil, "bit_field_0_0", "[0]", "ro", nil]
        ])
        expect(bit_fields[0].type).to be :ro
      end
    end

    it "アクセス属性はread-only" do
      bit_fields  = build_bit_fields([
        [nil, "register_0", "0x00", nil, "bit_field_0_0", "[0]", "ro", nil]
      ])
      expect(bit_fields[0]).to match_access(:read_only)
    end

    it "任意のビット幅を持つビットフィールドで使用できる" do
      expect {
        build_bit_fields([
          [nil, "register_0", "0x00", nil, "bit_field_0_0", "[0]"   , "ro", nil],
          [nil, "register_1", "0x04", nil, "bit_field_1_0", "[1:0]" , "ro", nil],
          [nil, "register_2", "0x08", nil, "bit_field_2_0", "[3:0]" , "ro", nil],
          [nil, "register_3", "0x0C", nil, "bit_field_3_0", "[7:0]" , "ro", nil],
          [nil, "register_4", "0x10", nil, "bit_field_4_0", "[15:0]", "ro", nil],
          [nil, "register_5", "0x14", nil, "bit_field_5_0", "[31:0]", "ro", nil]
        ])
      }.not_to raise_error
    end

    it "参照ビットフィールドの指定に有無にかかわらず使用できる" do
      expect {
        build_bit_fields([
          [nil, "register_0", "0x00", nil, "bit_field_0_0", "[0]"   , "ro", nil            ],
          [nil, "register_1", "0x04", nil, "bit_field_1_0", "[1:0]" , "ro", "bit_field_0_0"]
        ])
      }.not_to raise_error
    end
  end

  describe "#rtl" do
    before(:all) do
      register_map  = create_register_map(
        @configuration,
        "block_0" => [
          [nil, nil, "block_0"                                     ],
          [nil, nil, 256                                           ],
          [nil, nil, nil                                           ],
          [nil, nil, nil                                           ],
          [nil, 'register_0', "0x00-0x07", "[2]", 'bit_field_0_0', "[31:0]" , "ro", nil],
          [nil, 'register_1', "0x08"     , nil  , 'bit_field_1_0', "[31:16]", "ro", nil],
          [nil, nil         , nil        , nil  , 'bit_field_1_1', "[0]"    , "ro", nil]
        ]
      )
      @rtl  = build_rtl_factory.create(@configuration, register_map).bit_fields
    end

    let(:rtl) do
      @rtl
    end

    it "入力ポートvalue_inを持つ" do
      expect(rtl[0]).to have_input(:value_in, name: "i_bit_field_0_0", width: 32, dimensions: [2])
      expect(rtl[1]).to have_input(:value_in, name: "i_bit_field_1_0", width: 16)
      expect(rtl[2]).to have_input(:value_in, name: "i_bit_field_1_1", width: 1 )
    end

    describe "#generate_code" do
      it "#valueと#value_inを接続するコードを生成する" do
        expect(rtl[0]).to generate_code(:module_item, :top_down, "assign bit_field_0_0_value[g_i] = i_bit_field_0_0[g_i];\n")
        expect(rtl[1]).to generate_code(:module_item, :top_down, "assign bit_field_1_0_value = i_bit_field_1_0;\n")
        expect(rtl[2]).to generate_code(:module_item, :top_down, "assign bit_field_1_1_value = i_bit_field_1_1;\n")
      end
    end
  end
end
