require_relative '../spec_helper'

describe 'bit_field/reg_model_constructor' do
  include_context 'bit field type common'
  include_context 'configuration common'
  include_context 'ral common'

  before(:all) do
    enable :register_block, :name
    enable :register_block, :block_model_constructor

    configuration = create_configuration
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil, "block_0"]
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
function new(string name = "block_0");
  super.new(name);
endfunction
CODE
    end

    it "ブロックモデルのコンストラクタの定義を生成する" do
      expect(ral).to generate_code(:block_model_item, :top_down, expected_code)
    end
  end
end
