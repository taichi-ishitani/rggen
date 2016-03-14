require_relative '../spec_helper'

describe 'bit_field/reg_model_declaration' do
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
    @ral  = build_ral_factory.create(configuration, register_map).registers
  end

  after(:all) do
    clear_enabled_items
  end

  let(:ral) do
    @ral
  end

  describe "#generate_code" do
    it "レジスタモデルを宣言するコードを生成する" do
      expect(ral[0]).to generate_code(:reg_model_declaration, :top_down, "rand register_0_reg_model register_0;\n")
      expect(ral[1]).to generate_code(:reg_model_declaration, :top_down, "rand register_1_reg_model register_1[2];\n")
      expect(ral[2]).to generate_code(:reg_model_declaration, :top_down, "rand register_2_reg_model register_2[2][4];\n")
    end
  end
end
