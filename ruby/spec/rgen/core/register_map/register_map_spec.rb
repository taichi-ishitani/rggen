require_relative  '../../../spec_helper'

module RGen::RegisterMap
  describe RegisterMap do
    let(:register_map) do
      RegisterMap.new
    end

    let(:register_blocks) do
      2.times.map {RGen::RegisterMap::RegisterBlock::RegisterBlock.new(register_map)}
    end

    describe "#register_blocks" do
      before do
        register_blocks.each {|block| register_map.append_child(block)}
      end

      it "配下のレジスタブロックオブジェクト一覧返す" do
        expect(register_map.register_blocks).to match([
          eql(register_blocks[0]), eql(register_blocks[1])
        ])
      end
    end
  end
end
