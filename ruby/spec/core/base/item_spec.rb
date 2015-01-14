require_relative  '../../spec_helper'

module RegisterGenerator::Base
  describe Item do
    describe "#initialize" do
      it "自身を引数として、オーナーコンポーネントの#append_itemを呼び出す" do
        owner = Component.new
        allow(owner).to receive(:append_item)

        item  = Item.new(owner)
        expect(owner).to have_received(:append_item).with(item)
      end
    end

    describe "#owner" do
      it "オーナーコンポーネントを返す" do
        owner = Component.new
        item  = Item.new(owner)
        expect(item.owner).to eq owner
      end
    end
  end
end
