require_relative  '../../../spec_helper'

module RGen::RegisterMap
  describe RegisterMap do
    let(:register_map) do
      RegisterMap.new
    end

    let(:register_blocks) do
      2.times.map {RGen::RegisterMap::RegisterBlock::RegisterBlock.new(register_map)}
    end

    let(:registers) do
      2.times.flat_map do |i|
        2.times.map {RGen::RegisterMap::Register::Register.new(register_blocks[i])}
      end
    end

    before do
      register_blocks.each {|block| register_map.append_child(block)}
      registers.each_with_index {|register, i| register_blocks[i/2].append_child(register)}
    end

    describe "#register_blocks" do
      it "配下のレジスタブロックオブジェクト一覧返す" do
        expect(register_map.register_blocks).to match([
          eql(register_blocks[0]), eql(register_blocks[1])
        ])
      end
    end

    describe "#registers" do
      it "配下のレジスタオブジェクト一覧を返す" do
        expect(register_map.registers).to match([
          eql(registers[0]), eql(registers[1]), eql(registers[2]), eql(registers[3])
        ])
      end
    end
  end
end
