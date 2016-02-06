require_relative '../spec_helper'

describe 'bit_fields/type/reserved' do
  include_context 'bit field type common'
  include_context 'configuration common'
  include_context 'ral common'

  before(:all) do
    enable :register_block, :name
    enable :register, :name
    enable :bit_field, [:name, :bit_assignment, :type, :reference]
    enable :bit_field, :type, [:reserved, :rw]

    @factory                = build_register_map_factory
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
          [nil, "register_0", "bit_field_0_0", "[0]", "reserved", nil]
        ])
        expect(bit_fields[0].type).to be :reserved
      end
    end

    it "アクセス属性はreserved" do
      bit_fields  = build_bit_fields([
        [nil, "register_0", "bit_field_0_0", "[0]", "reserved", nil]
      ])
      expect(bit_fields[0]).to match_access(:reserved)
    end

    it "任意のビット幅を持つビットフィールドで使用できる" do
      expect {
        build_bit_fields([
          [nil, "register_0", "bit_field_0_0", "[0]"   , "reserved", nil],
          [nil, "register_1", "bit_field_1_0", "[1:0]" , "reserved", nil],
          [nil, "register_2", "bit_field_2_0", "[3:0]" , "reserved", nil],
          [nil, "register_3", "bit_field_3_0", "[7:0]" , "reserved", nil],
          [nil, "register_4", "bit_field_4_0", "[15:0]", "reserved", nil],
          [nil, "register_5", "bit_field_5_0", "[31:0]", "reserved", nil]
        ])
      }.not_to raise_error
    end

    it "参照ビットフィールドの指定に有無にかかわらず使用できる" do
      expect {
        build_bit_fields([
          [nil, "register_0", "bit_field_0_0", "[0]" , "rw"      , nil            ],
          [nil, "register_1", "bit_field_1_0", "[0]" , "reserved", nil            ],
          [nil, "register_2", "bit_field_2_0", "[0]" , "reserved", "bit_field_0_0"]
        ])
      }.not_to raise_error
    end
  end

  describe "ral" do
    let(:register_map) do
      set_load_data([
        [nil, "register_0", "bit_field_0_0", "[0]", "reserved", nil]
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
  end
end
