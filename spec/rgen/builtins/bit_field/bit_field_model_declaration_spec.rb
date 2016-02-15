require_relative '../spec_helper'

describe 'bit_field/bit_field_model_declaration' do
  include_context 'bit field type common'
  include_context 'configuration common'
  include_context 'ral common'

  before(:all) do
    enable :global, :data_width
    enable :register_block, :name
    enable :register, :name
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field, :type, [:rw, :ro, :reserved]
    enable :bit_field, :bit_field_model_declaration

    configuration = create_configuration
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil         ,"block_0"                                    ],
        [                                                               ],
        [                                                               ],
        [nil, "register_0", "bit_field_0_0", "[2]", "rw"      , 0  , nil],
        [nil, nil         , "bit_field_0_1", "[1]", "ro"      , nil, nil],
        [nil, nil         , "bit_field_0_2", "[0]", "reserved", nil, nil]
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

  describe "#create_code" do
    it "ビットフィールドモデルを宣言するコードを生成する" do
      expect(ral[0]).to generate_code(:bit_field_model_declaration, :top_down, "rand rgen_ral_field bit_field_0_0;")
      expect(ral[1]).to generate_code(:bit_field_model_declaration, :top_down, "rand rgen_ral_field bit_field_0_1;")
      expect(ral[2]).to generate_code(:bit_field_model_declaration, :top_down, "rand rgen_ral_field bit_field_0_2;")
    end
  end
end
