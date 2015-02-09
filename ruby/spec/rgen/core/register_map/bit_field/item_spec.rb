require_relative  '../../../../spec_helper'

module RGen::RegisterMap::BitField
  describe Item do
    let(:register_map) do
      RGen::RegisterMap::RegisterMap.new
    end

    let(:register_block) do
      RGen::RegisterMap::RegisterBlock::RegisterBlock.new(register_map)
    end

    let(:register) do
      RGen::RegisterMap::Register::Register.new(register_block)
    end

    let(:bit_field) do
      BitField.new(register)
    end

    let(:item) do
      Item.new(bit_field)
    end

    describe "#register_map" do
      it "オーナーのビットフィールドオブジェクトが属するレジスタマップオブジェクトを返す" do
        expect(item.register_map).to eql register_map
      end
    end

    describe "#register_block" do
      it "オーナーのビットフィールドオブジェクトが属するレジスタブロックオブジェクトを返す" do
        expect(item.register_block).to eql register_block
      end
    end

    describe "#register" do
      it "オーナーのビットフィールドオブジェクトが属するレジスタオブジェクトを返す" do
        expect(item.register).to eql register
      end
    end

    describe "#bit_field" do
      it "オーナーのビットフィールドオブジェクトを返す" do
        expect(item.bit_field).to eql bit_field
      end
    end
  end
end
