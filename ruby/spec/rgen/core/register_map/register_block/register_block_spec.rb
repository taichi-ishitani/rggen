require_relative  '../../../../spec_helper'

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

    before do
      register_map.append_child(register_block)
      registers.each {|register| register_block.append_child(register)}
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
  end
end
