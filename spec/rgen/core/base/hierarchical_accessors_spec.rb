require_relative  '../../../spec_helper'

module RGen::Base
  describe HierarchicalAccessors do
    class TestComponent
      include HierarchicalStructure
      include HierarchicalAccessors

      def initialize(parent = nil)
        super(parent)
        parent.add_child(self) unless parent.nil?
        define_hierarchical_accessors
      end
    end

    before(:all) do
      @register_map     = TestComponent.new
      @register_blocks  = 2.times.map {TestComponent.new(@register_map)}
      @registers        = 2.times.flat_map {|i| 2.times.map {TestComponent.new(@register_blocks[i])}}
      @bit_fields       = 4.times.flat_map {|i| 2.times.map {TestComponent.new(@registers[i]      )}}
    end

    let(:register_map) do
      @register_map
    end

    let(:register_blocks) do
      @register_blocks
    end

    let(:register_block) do
      register_blocks.first
    end

    let(:registers) do
      @registers
    end

    let(:register) do
      registers.first
    end

    let(:bit_fields) do
      @bit_fields
    end

    let(:bit_field) do
      bit_fields.first
    end

    context "#levelが0の場合" do
      describe "#hierarchy" do
        it ":register_mapを返す" do
          expect(register_map.hierarchy).to eq :register_map
        end
      end

      describe "#register_blocks" do
        it "配下のレジスタブロックオブジェクトを返す" do
          expect(register_map.register_blocks).to match([
            eql(register_blocks[0]), eql(register_blocks[1])
          ])
        end
      end

      describe "#registers" do
        it "配下のレジスタブロックオブジェクト一覧を返す" do
          expect(register_map.registers).to match([
            eql(registers[0]), eql(registers[1]), eql(registers[2]), eql(registers[3])
          ])
        end
      end

      describe "#bit_fields" do
        it "配下のビットフィールドオブジェクトを返す" do
          expect(register_map.bit_fields).to match([
            eql(bit_fields[0]), eql(bit_fields[1]), eql(bit_fields[2]), eql(bit_fields[3]),
            eql(bit_fields[4]), eql(bit_fields[5]), eql(bit_fields[6]), eql(bit_fields[7])
          ])
        end
      end
    end

    context "#levelが1の場合" do
      describe "#hierarchy" do
        it ":register_blockを返す" do
          expect(register_block.hierarchy).to eq :register_block
        end
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

    context "#levelが2の場合" do
      describe "#hierarchy" do
        it ":registerを返す" do
          expect(register.hierarchy).to eq :register
        end
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

    context "#levelが3の場合" do
      describe "#hierarchy" do
        it ":registerを返す" do
          expect(bit_field.hierarchy).to eq :bit_field
        end
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
        it "属するレジスタブオブジェクトを返す" do
          expect(bit_field.register).to eql register
        end
      end
    end
  end
end
