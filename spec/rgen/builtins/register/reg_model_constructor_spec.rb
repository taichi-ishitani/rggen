require_relative '../spec_helper'

describe 'bit_field/reg_model_constructor' do
  include_context 'bit field type common'
  include_context 'configuration common'
  include_context 'ral common'

  before(:all) do
    enable :global, :data_width
    enable :register_block, :name
    enable :register, :name
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field, :type, [:rw]
    enable :register , :reg_model_constructor

    configuration = create_configuration
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil         ,"block_0"                                   ],
        [                                                              ],
        [                                                              ],
        [nil, "register_0", "bit_field_0_0", "[0]" , "rw"      , 0, nil],
        [nil, "register_1", "bit_field_1_0", "[7]" , "rw"      , 0, nil],
        [nil, "register_2", "bit_field_2_0", "[8]" , "rw"      , 0, nil],
        [nil, nil         , "bit_field_2_1", "[7]" , "rw"      , 0, nil],
        [nil, "register_3", "bit_field_3_0", "[31]", "rw"      , 0, nil],
        [nil, nil         , "bit_field_3_1", "[0]" , "rw"      , 0, nil]
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
    let(:expected_code_0) do
      <<'CODE'
function new(string name = "register_0");
  super.new(name, 8, 0);
endfunction
CODE
    end

    let(:expected_code_1) do
      <<'CODE'
function new(string name = "register_1");
  super.new(name, 8, 0);
endfunction
CODE
    end

    let(:expected_code_2) do
      <<'CODE'
function new(string name = "register_2");
  super.new(name, 16, 0);
endfunction
CODE
    end

    let(:expected_code_3) do
      <<'CODE'
function new(string name = "register_3");
  super.new(name, 32, 0);
endfunction
CODE
    end

    it "レジスタモデルのコンストラクタの定義を生成する" do
      expect(ral[0]).to generate_code(:reg_model_item, :top_down, expected_code_0)
      expect(ral[1]).to generate_code(:reg_model_item, :top_down, expected_code_1)
      expect(ral[2]).to generate_code(:reg_model_item, :top_down, expected_code_2)
      expect(ral[3]).to generate_code(:reg_model_item, :top_down, expected_code_3)
    end
  end
end
