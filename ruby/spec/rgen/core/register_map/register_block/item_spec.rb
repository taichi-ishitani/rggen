require_relative  '../../../../spec_helper'

module RGen::RegisterMap::RegisterBlock
  describe Item do
    let(:register_map) do
      RGen::RegisterMap::RegisterMap.new
    end

    let(:register_block) do
      RegisterBlock.new(register_map)
    end

    let(:item) do
      Item.new(register_block)
    end

    describe "#register_map" do
      it "オーナーのレジスタブロックオブジェクトが属するレジスタマップオブジェクトを返す" do
        expect(item.register_map).to eql register_map
      end
    end

    describe "#register_block" do
      it "オーナーのレジスタブロックオブジェクトを返す" do
        expect(item.register_block).to eql register_block
      end
    end
  end
end
