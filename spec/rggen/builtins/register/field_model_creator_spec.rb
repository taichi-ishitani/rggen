require_relative '../spec_helper'

describe 'register/field_model_creator' do
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
    enable :register , :field_model_creator

    configuration = create_configuration
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil         ,"block_0"                                             ],
        [                                                                        ],
        [                                                                        ],
        [nil, "register_0", "bit_field_0_0", "[31:16]", "rw"      , "0x0123", nil],
        [nil, nil         , "bit_field_0_1", "[9:8]"  , "ro"      , nil     , nil],
        [nil, nil         , "bit_field_0_2", "[4]"    , "ro"      , 1       , nil],
        [nil, nil         , "bit_field_0_3", "[0]"    , "reserved", nil     , nil]
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

  describe "#generate_code" do
    let(:expected_code) do
      <<'CODE'
function void create_fields();
  `rggen_ral_create_field_model(bit_field_0_0, "bit_field_0_0", 16, 16, "RW", 0, 16'h0123, 1, "g_bit_field_0_0.u_bit_field.value")
  `rggen_ral_create_field_model(bit_field_0_1, "bit_field_0_1", 2, 8, "RO", 0, 2'h0, 0, "g_bit_field_0_1.u_bit_field.i_value")
  `rggen_ral_create_field_model(bit_field_0_2, "bit_field_0_2", 1, 4, "RO", 0, 1'h1, 1, "g_bit_field_0_2.u_bit_field.i_value")
  `rggen_ral_create_field_model(bit_field_0_3, "bit_field_0_3", 1, 0, "RO", 0, 1'h0, 0, "")
endfunction
CODE
    end

    it "ビットフィールドモデルを生成するcreate_fieldsメソッドの定義を生成する" do
      expect(ral).to generate_code(:reg_model_item, :top_down, expected_code)
    end
  end
end
