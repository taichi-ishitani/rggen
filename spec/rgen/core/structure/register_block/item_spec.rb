require_relative  '../spec_helper'

module RGen::Structure::RegisterBlock
  describe Item do
    include_context 'structured components'

    let(:item) do
      Class.new(RGen::Base::Item) {
        include Item
      }.new(register_block)
    end

    describe "#register_map" do
      it "オーナーのレジスタブロックオブジェクトが属するレジスタマップオブジェクトを返す" do
        expect(item.register_map).to eql register_map
      end
    end

    describe "#register_block" do
      it "オーナーのレジスタブロックオブジェクトを返す" do
        expect(item.register_block).to eql register_block
      end
    end
  end
end
