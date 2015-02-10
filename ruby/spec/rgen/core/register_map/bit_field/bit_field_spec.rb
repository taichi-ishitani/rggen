require_relative  '../spec_helper'

module RGen::RegisterMap::BitField
  describe BitField do
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

    describe "#register_map" do
      it "属するレジスタマップオブジェクトを返す" do
        expect(bit_field.register_map).to eql register_map
      end
    end

    describe "#register_block" do
      it "属するレジスタブロックオブジェクトを返す" do
        expect(bit_field.register_block).to eql register_block
      end
    end

    describe "#register" do
      it "属するレジスタオブジェクトを返す" do
        expect(bit_field.register).to eql register
      end
    end
  end
end