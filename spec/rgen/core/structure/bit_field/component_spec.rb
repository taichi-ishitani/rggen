require_relative  '../spec_helper'

module RGen::Structure::BitField
  describe Component do
    include_context 'structured components'

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
