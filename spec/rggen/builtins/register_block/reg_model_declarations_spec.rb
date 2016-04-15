require_relative '../spec_helper'

describe 'register_block/reg_model_declarations' do
  include_context 'bit field type common'
  include_context 'configuration common'
  include_context 'ral common'

  before(:all) do
    enable :global, [:data_width, :address_width]
    enable :register_block, [:name, :byte_size]
    enable :register , [:name, :offset_address, :array, :shadow, :accessibility]
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field, :type, :rw
    enable :register , [:reg_model_declaration, :reg_model_definition]
    enable :register_block, :reg_model_declarations

    configuration = create_configuration
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil, "block_0"                                                                                               ],
        [nil, nil, 256                                                                                                     ],
        [                                                                                                                  ],
        [                                                                                                                  ],
        [nil, "register_0", "0x00"     , nil     , nil                           , "bit_field_0_0", "[31:16]", "rw", 0, nil],
        [nil, nil         , nil        , nil     , nil                           , "bit_field_0_1", "[15: 0]", "rw", 0, nil],
        [nil, "register_1", "0x04-0x0B", "[2]"   , nil                           , "bit_field_1_0", "[31:16]", "rw", 0, nil],
        [nil, nil         , nil        , nil     , nil                           , "bit_field_1_1", "[15: 0]", "rw", 0, nil],
        [nil, "register_2", "0x0C"     , "[2, 4]", "bit_field_0_0, bit_field_0_1", "bit_field_2_0", "[31:16]", "rw", 0, nil],
        [nil, nil         , nil        , nil     , nil                           , "bit_field_2_1", "[15: 0]", "rw", 0, nil]
      ]
    )
    @ral  = build_ral_factory.create(configuration, register_map).register_blocks[0]
  end

  after(:all) do
    clear_enabled_items
  end

  let(:ral) do
    @ral
  end

  describe "#generate_code" do
    let(:expected_code) do
      <<'CODE'
rand register_0_reg_model register_0;
rand register_1_reg_model register_1[2];
rand register_2_reg_model register_2[2][4];
CODE
    end

    it "レジスタモデルを宣言するコードを生成する" do
      expect(ral).to generate_code(:block_model_item, :top_down, expected_code)
    end
  end
end
