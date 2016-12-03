require_relative '../spec_helper'

describe 'register/indirect_index_configurator' do
  include_context 'bit field type common'
  include_context 'configuration common'
  include_context 'ral common'

  before(:all) do
    enable :global, [:data_width, :address_width]
    enable :register_block, [:name, :byte_size]
    enable :register , [:name, :offset_address, :array, :type]
    enable :register , :type, :indirect
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field, :type, [:rw]
    enable :register , :indirect_index_configurator

    configuration = create_configuration
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil         ,"block_0"                                                                                                                             ],
        [nil, nil         , 256                                                                                                                                  ],
        [                                                                                                                                                        ],
        [                                                                                                                                                        ],
        [nil, "register_0", "0x00", nil    , nil                                                                       , "bit_field_0_0", "[31:24]", "rw", 0, nil],
        [nil, nil         , nil   , nil    , nil                                                                       , "bit_field_0_1", "[23:16]", "rw", 0, nil],
        [nil, "register_1", "0x04", nil    , nil                                                                       , "bit_field_1_0", "[15: 8]", "rw", 0, nil],
        [nil, nil         , nil   , nil    , nil                                                                       , "bit_field_1_1", "[ 7: 0]", "rw", 0, nil],
        [nil, "register_2", "0x10", nil    , "indirect: bit_field_0_0:0"                                               , "bit_field_2_0", "[31: 0]", "rw", 0, nil],
        [nil, "register_3", "0x14", "[4]"  , "indirect: bit_field_0_0  "                                               , "bit_field_3_0", "[31: 0]", "rw", 0, nil],
        [nil, "register_4", "0x18", "[2,4]", "indirect: bit_field_0_0:0, bit_field_0_1, bit_field_1_0, bit_field_1_1:3", "bit_field_4_0", "[31: 0]", "rw", 0, nil]
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
    context "間接参照レジスタではない場合" do
      it "コードの生成を行わない" do
        expect(ral[0]).to generate_code(:reg_model_item, :top_down, "")
      end
    end

    context "間接参照レジスタの場合" do
      let(:expected_code_2) do
        <<'CODE'
function void configure_indirect_indexes();
  set_indirect_index("register_0", "bit_field_0_0", 0);
endfunction
CODE
      end

      let(:expected_code_3) do
        <<'CODE'
function void configure_indirect_indexes();
  set_indirect_index("register_0", "bit_field_0_0", indexes[0]);
endfunction
CODE
      end

      let(:expected_code_4) do
        <<'CODE'
function void configure_indirect_indexes();
  set_indirect_index("register_0", "bit_field_0_0", 0);
  set_indirect_index("register_0", "bit_field_0_1", indexes[0]);
  set_indirect_index("register_1", "bit_field_1_0", indexes[1]);
  set_indirect_index("register_1", "bit_field_1_1", 3);
endfunction
CODE
      end

      it "間接参照インデックスの設定を行うconfigure_indirect_indexesメソッドの定義を生成する" do
        expect(ral[2]).to generate_code(:reg_model_item, :top_down, expected_code_2)
        expect(ral[3]).to generate_code(:reg_model_item, :top_down, expected_code_3)
        expect(ral[4]).to generate_code(:reg_model_item, :top_down, expected_code_4)
      end
    end
  end
end