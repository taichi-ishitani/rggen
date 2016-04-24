require_relative '../spec_helper'

describe 'bit_field/field_model' do
  include_context 'bit field type common'
  include_context 'configuration common'
  include_context 'ral common'

  before(:all) do
    enable :global, :data_width
    enable :register_block, :name
    enable :register, :name
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field, :type, [:rw, :ro, :reserved]
    enable :bit_field, :field_model

    configuration = create_configuration
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil         ,"block_0"                                            ],
        [                                                                       ],
        [                                                                       ],
        [nil, "register_0", "bit_field_0_0", "[31:0]", "rw"      , "0x0123", nil],
        [nil, "register_1", "bit_field_1_0", "[9:8]" , "ro"      , nil     , nil],
        [nil, nil         , "bit_field_1_1", "[4]"   , "ro"      , 1       , nil],
        [nil, nil         , "bit_field_1_2", "[0]"   , "reserved", nil     , nil]
      ]
    )
    @ral  = build_ral_factory.create(configuration, register_map)
  end

  after(:all) do
    clear_enabled_items
  end

  let(:registers) do
    @ral.registers
  end

  let(:bit_fields) do
    @ral.bit_fields
  end

  describe "#build" do
    it "親コンポーネントに自身の宣言を追加する" do
      expect(registers[0]).to have_sub_model(:rggen_ral_field, 'bit_field_0_0')
      expect(registers[1]).to have_sub_model(:rggen_ral_field, 'bit_field_1_0')
      expect(registers[1]).to have_sub_model(:rggen_ral_field, 'bit_field_1_1')
      expect(registers[1]).to have_sub_model(:rggen_ral_field, 'bit_field_1_2')
    end
  end

  describe "#model_creation" do
    before do
      bit_fields.each do |bit_field|
        bit_field.model_creation(code)
      end
    end

    let(:code) do
      RgGen::OutputBase::CodeBlock.new
    end

    let(:expected_code) do
      [
        "`rggen_ral_create_field_model(bit_field_0_0, \"bit_field_0_0\", 32, 0, \"RW\", 0, 32'h00000123, 1)\n",
        "`rggen_ral_create_field_model(bit_field_1_0, \"bit_field_1_0\", 2, 8, \"RO\", 0, 2'h0, 0)\n",
        "`rggen_ral_create_field_model(bit_field_1_1, \"bit_field_1_1\", 1, 4, \"RO\", 0, 1'h1, 1)\n",
        "`rggen_ral_create_field_model(bit_field_1_2, \"bit_field_1_2\", 1, 0, \"RO\", 0, 1'h0, 0)\n"
      ].join
    end

    it "ビットフィールドモデルを生成するコードを生成する" do
      expect(code.to_s).to eq expected_code
    end
  end
end