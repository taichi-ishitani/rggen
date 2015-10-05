require_relative '../spec_helper'

describe 'bit_fields/type/rw' do
  include_context 'bit field type common'
  include_context 'configuration common'

  before(:all) do
    RGen.enable(:global, :data_width)
    RGen.enable(:register_block, :name)
    RGen.enable(:register, :name)
    RGen.enable(:bit_field, [:name, :bit_assignment, :type, :reference])
    RGen.enable(:bit_field, :type, :rw)

    @configuration_factory  = build_configuration_factory
    @factory                = build_register_map_factory
  end

  after(:all) do
    clear_enabled_items
  end

  let(:configuration) do
    ConfigurationDummyLoader.load_data({})
    @configuration_factory.create(configuration_file)
  end

  describe "#type" do
    it ":rwを返す" do
      bit_fields  = build_bit_fields([
        [nil, "register_0", "bit_field_0_0", "[0]", "rw", nil]
      ])
      expect(bit_fields[0].type).to be :rw
    end
  end

  it "アクセス属性はread-write" do
    bit_fields  = build_bit_fields([
      [nil, "register_0", "bit_field_0_0", "[0]", "rw", nil]
    ])
    expect(bit_fields[0]).to match_access(:read_write)
  end

  it "任意のビット幅を持つビットフィールドで使用できる" do
    expect {
      build_bit_fields([
        [nil, "register_0", "bit_field_0_0", "[0]"   , "rw", nil],
        [nil, "register_1", "bit_field_1_0", "[1:0]" , "rw", nil],
        [nil, "register_2", "bit_field_2_0", "[3:0]" , "rw", nil],
        [nil, "register_3", "bit_field_3_0", "[7:0]" , "rw", nil],
        [nil, "register_4", "bit_field_4_0", "[15:0]", "rw", nil],
        [nil, "register_5", "bit_field_5_0", "[31:0]", "rw", nil]
      ])
    }.not_to raise_error
  end

  it "参照ビットフィールドの指定に有無にかかわらず使用できる" do
    expect {
      build_bit_fields([
        [nil, "register_0", "bit_field_0_0", "[0]"   , "rw", nil            ],
        [nil, "register_1", "bit_field_1_0", "[1:0]" , "rw", "bit_field_0_0"]
      ])
    }.not_to raise_error
  end
end
