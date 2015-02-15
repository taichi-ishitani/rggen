require_relative  '../spec_helper'

module RGen::RegisterMap::RegisterBlock
  describe RegisterBlock do
    let(:register_map) do
      RGen::RegisterMap::RegisterMap.new
    end

    let(:register_block) do
      RegisterBlock.new(register_map)
    end

    let(:registers) do
      2.times.map {RGen::RegisterMap::Register::Register.new(register_block)}
    end

    let(:bit_fields) do
      2.times.flat_map do |i|
        2.times.map {RGen::RegisterMap::BitField::BitField.new(registers[i])}
      end
    end

    before do
      register_map.append_child(register_block)
      registers.each {|register| register_block.append_child(register)}
      bit_fields.each_with_index {|bit_field, i| registers[i/2].append_child(bit_field)}
    end

    describe "#register_map" do
      it "属するレジスタマップオブジェクトを返す" do
        expect(register_block.register_map).to eql register_map
      end
    end

    describe "#registers" do
      it "配下のレジスタオブジェクト一覧を返す" do
        expect(register_block.registers).to match([
          eql(registers[0]), eql(registers[1])
        ])
      end
    end

    describe "#bit_fields" do
      it "配下のビットフィールドオブジェクト一覧を返す" do
        expect(register_block.bit_fields).to match([
          eql(bit_fields[0]), eql(bit_fields[1]), eql(bit_fields[2]), eql(bit_fields[3])
        ])
      end
    end
  end
end
