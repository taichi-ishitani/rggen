require_relative  '../../../spec_helper'

module RGen::Base
  describe HierarchicalItemAccessors do
    class TestItem < Item
      include HierarchicalItemAccessors
      def initialize(owner)
        super(owner)
        define_hierarchical_item_accessors
      end
    end

    before(:all) do
      @register_map   = Component.new
      @register_block = Component.new(@register_map)
      @register       = Component.new(@register_block)
      @bit_field      = Component.new(@register)
    end

    let(:register_map) do
      @register_map
    end

    let(:register_block) do
      @register_block
    end

    let(:register) do
      @register
    end

    let(:bit_field) do
      @bit_field
    end

    context "ownerの#levelが0の場合" do
      let(:item) do
        TestItem.new(register_map)
      end

      describe "#hierarchy" do
        it ":register_mapを返す" do
          expect(item.hierarchy).to eq :register_map
        end
      end

      describe "#register_map" do
        it "#ownerを返す" do
          expect(item.register_map).to eql register_map
        end
      end
    end

    context "ownerの#levelが1の場合" do
      let(:item) do
        TestItem.new(register_block)
      end

      describe "#hierarchy" do
        it ":register_blockを返す" do
          expect(item.hierarchy).to eq :register_block
        end
      end

      describe "#register_map" do
        it "#register_blockの親オブジェクトを返す" do
          expect(item.register_map).to eql register_map
        end
      end

      describe "#register_block" do
        it "#ownerを返す" do
          expect(item.register_block).to eql register_block
        end
      end
    end

    context "ownerの#levelが2の場合" do
      let(:item) do
        TestItem.new(register)
      end

      describe "#hierarchy" do
        it ":registerを返す" do
          expect(item.hierarchy).to eq :register
        end
      end

      describe "#register_map" do
        it "#register_blockの親オブジェクトを返す" do
          expect(item.register_map).to eql register_map
        end
      end

      describe "#register_block" do
        it "#registerの親オブジェクトを返す" do
          expect(item.register_block).to eql register_block
        end
      end

      describe "#register" do
        it "#ownerを返す" do
          expect(item.register).to eql register
        end
      end
    end

    context "ownerの#levelが3の場合" do
      let(:item) do
        TestItem.new(bit_field)
      end

      describe "#hierarchy" do
        it ":bit_fieldを返す" do
          expect(item.hierarchy).to eq :bit_field
        end
      end

      describe "#register_map" do
        it "#register_blockの親オブジェクトを返す" do
          expect(item.register_map).to eql register_map
        end
      end

      describe "#register_block" do
        it "#registerの親オブジェクトを返す" do
          expect(item.register_block).to eql register_block
        end
      end

      describe "#register" do
        it "#bit_fieldの親オブジェクトを返す" do
          expect(item.register).to eql register
        end
      end

      describe "#bit_field" do
        it "#ownerを返す" do
          expect(item.bit_field).to eql bit_field
        end
      end
    end
  end
end
