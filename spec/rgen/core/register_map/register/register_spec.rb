require_relative  '../spec_helper'

module RGen::RegisterMap::Register
  describe Register do
    let(:register_map) do
      RGen::RegisterMap::RegisterMap.new
    end

    let(:register_block) do
      RGen::RegisterMap::RegisterBlock::RegisterBlock.new(register_map)
    end

    let(:register) do
      RGen::RegisterMap::Register::Register.new(register_block)
    end

    let(:bit_fields) do
      2.times.map {RGen::RegisterMap::BitField::BitField.new(register)}
    end

    before do
      bit_fields.each {|bit_field| register.append_child(bit_field)}
    end

    describe "#register_map" do
      it "属するレジスタマップオブジェクトを返す" do
        expect(register.register_map).to eql register_map
      end
    end

    describe "#register_block" do
      it "属するレジスタブロックオブジェクトを返す" do
        expect(register.register_block).to eql register_block
      end
    end

    describe "#bit_fields" do
      it "配下のビットフィールドオブジェクト一覧を返す" do
        expect(register.bit_fields).to match([
          eql(bit_fields[0]), eql(bit_fields[1])
        ])
      end
    end
  end
end
