require_relative '../spec_helper'

describe 'register_block/reg_model_constructor' do
  include_context 'bit field type common'
  include_context 'configuration common'
  include_context 'ral common'

  before(:all) do
    enable :global, :data_width
    enable :register_block, :name
    enable :register_block, :block_model_default_map_creator
  end

  after(:all) do
    clear_enabled_items
  end

  let(:configurations) do
    2.times.map do |i|
      create_configuration(data_width: 32 * (i + 1))
    end
  end

  let(:register_maps) do
    2.times.map do |i|
      create_register_map(
        configurations[i],
        "block_0" => [
          [nil, nil, "block_0"]
        ]
      )
    end
  end

  let(:ral) do
    2.times.map do |i|
      build_ral_factory.create(configurations[i], register_maps[i]).register_blocks[0]
    end
  end

  describe "#generate_code" do
    let(:expected_code_0) do
      <<'CODE'
function uvm_reg_map create_default_map();
  return create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN, 1);
endfunction
CODE
    end

    let(:expected_code_1) do
      <<'CODE'
function uvm_reg_map create_default_map();
  return create_map("default_map", 0, 8, UVM_LITTLE_ENDIAN, 1);
endfunction
CODE
    end

    it "デフォルトのマップオブジェクトを生成するcreate_default_mapメソッドの定義を生成する" do
      expect(ral[0]).to generate_code(:block_model_item, :top_down, expected_code_0)
      expect(ral[1]).to generate_code(:block_model_item, :top_down, expected_code_1)
    end
  end
end
