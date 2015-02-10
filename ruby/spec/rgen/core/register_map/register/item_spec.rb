require_relative  '../spec_helper'

module RGen::RegisterMap::Register
  describe Item do
    let(:register_map) do
      RGen::RegisterMap::RegisterMap.new
    end

    let(:register_block) do
      RGen::RegisterMap::RegisterBlock::RegisterBlock.new(register_map)
    end

    let(:register) do
      Register.new(register_block)
    end

    let(:item) do
      Item.new(register)
    end

    describe "#register_map" do
      it "オーナーのレジスタオブジェクトが属するレジスタマップオブジェクトを返す" do
        expect(item.register_map).to eql register_map
      end
    end

    describe "#register_block" do
      it "オーナーのレジスタオブジェクトが属するレジスタブロックオブジェクトを返す" do
        expect(item.register_block).to eql register_block
      end
    end

    describe "#register" do
      it "オーナーのレジスタオブジェクトを返す" do
        expect(item.register).to eql register
      end
    end
  end
end
