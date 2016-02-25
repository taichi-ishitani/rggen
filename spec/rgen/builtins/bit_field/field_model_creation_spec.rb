require_relative '../spec_helper'

describe 'bit_field/field_model_declaration' do
  include_context 'bit field type common'
  include_context 'configuration common'
  include_context 'ral common'

  before(:all) do
    enable :global, :data_width
    enable :register_block, :name
    enable :register, :name
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field, :type, [:rw, :ro, :reserved]
    enable :bit_field, :field_model_creation

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
    @ral  = build_ral_factory.create(configuration, register_map).bit_fields
  end

  after(:all) do
    clear_enabled_items
  end

  let(:ral) do
    @ral
  end

  describe "#generate_code" do
    let(:expected_code) do
      [
        "`rgen_ral_create_field_model(bit_field_0_0, \"bit_field_0_0\", 32, 0, \"RW\", 0, 32'h00000123, 1)",
        "`rgen_ral_create_field_model(bit_field_1_0, \"bit_field_1_0\", 2, 8, \"RO\", 0, 2'h0, 0)",
        "`rgen_ral_create_field_model(bit_field_1_1, \"bit_field_1_1\", 1, 4, \"RO\", 0, 1'h1, 1)",
        "`rgen_ral_create_field_model(bit_field_1_2, \"bit_field_1_2\", 1, 0, \"RO\", 0, 1'h0, 0)"
      ]
    end

    it "ビットフィールドモデルを生成するコードを生成する" do
      expect(ral[0]).to generate_code(:field_model_creation, :top_down, expected_code[0])
      expect(ral[1]).to generate_code(:field_model_creation, :top_down, expected_code[1])
      expect(ral[2]).to generate_code(:field_model_creation, :top_down, expected_code[2])
      expect(ral[3]).to generate_code(:field_model_creation, :top_down, expected_code[3])
    end
  end
end