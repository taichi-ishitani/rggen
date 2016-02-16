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
    enable :bit_field, :field_model_declaration
    enable :register , :field_model_declarations

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
    @ral  = build_ral_factory.create(configuration, register_map).registers[0]
  end

  after(:all) do
    clear_enabled_items
  end

  let(:ral) do
    @ral
  end

  describe "#create_code" do
    let(:expected_code) do
      <<'CODE'
rand rgen_ral_field bit_field_0_0;
rand rgen_ral_field bit_field_0_1;
rand rgen_ral_field bit_field_0_2;
CODE
    end

    it "レジスタモデル内で使用するビットフィールドモデルを宣言するコードを生成する" do
      expect(ral).to generate_code(:reg_model_item, :top_down, expected_code)
    end
  end
end
