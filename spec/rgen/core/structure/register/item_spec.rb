require_relative  '../spec_helper'

module RGen::Structure::Register
  describe Item do
    include_context 'structured components'

    let(:item) do
      Class.new(RGen::Base::Item) {
        include Item
      }.new(register)
    end

    describe "#register_map" do
      it "オーナーのレジスタオブジェクトが属するレジスタマップオブジェクトを返す" do
        expect(item.register_map).to eql register_map
      end
    end

    describe "#register_block" do
      it "オーナーのレジスタオブジェクトが属するレジスタブロックオブジェクトを返す" do
        expect(item.register_block).to eql register_block
      end
    end

    describe "#register" do
      it "オーナーのレジスタオブジェクトを返す" do
        expect(item.register).to eql register
      end
    end
  end
end
