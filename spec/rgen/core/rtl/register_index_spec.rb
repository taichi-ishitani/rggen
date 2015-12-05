require_relative '../../../spec_helper'

module RGen::Rtl
  describe RegisterIndex do
    describe "#register_index" do
      let(:register_map) do
        Component.new(nil)
      end

      let(:register_blocks) do
        2.times.map {
          register_block  = Component.new(register_map)
          register_map.add_child(register_block)
          register_block
        }
      end

      let(:registers) do
        4.times.map do |i|
          register  = Component.new(register_blocks[i / 2])
          register_blocks[i / 2].add_child(register)
          register
        end
      end

      let(:item_class) do
        Class.new(Item) {include RegisterIndex}
      end

      context "階層がレジスタの場合" do
        let(:items) do
          8.times.map do |i|
            item  = item_class.new(registers[i / 2])
            registers[i / 2].add_item(item)
            item
          end
        end

        it "自身が属するレジスタのレジスタブロック内でのインデックスを返す" do
          expect(items.map {|i| i.send(:register_index)}).to match [0, 0, 1, 1, 0, 0, 1, 1]
        end
      end

      context "階層がビットフィールドの場合" do
        let(:bit_fields) do
          8.times.map do |i|
            bit_field = Component.new(registers[i / 2])
            registers[i / 2].add_child(bit_field)
            bit_field
          end
        end

        let(:items) do
          16.times.map do |i|
            item  = item_class.new(bit_fields[i / 2])
            bit_fields[i / 2].add_item(item)
            item
          end
        end

        it "自身が属するビットフィールドが属するレジスタのレジスタブロック内でのインデックスを返す" do
          expect(items.map {|i| i.send(:register_index)}).to match [
            0, 0, 0, 0, 1, 1, 1, 1,
            0, 0, 0, 0, 1, 1, 1, 1
          ]
        end
      end
    end
  end
end
