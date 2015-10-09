require_relative  '../spec_helper'

module RGen::Structure::BitField
  describe Item do
    include_context 'structured components'

    let(:item) do
      Class.new(RGen::Base::Item) {
        include Item
      }.new(bit_field)
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
