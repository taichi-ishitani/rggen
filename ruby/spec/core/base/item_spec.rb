require_relative  '../../spec_helper'

module RGen::Base
  describe Item do
    describe "#owner" do
      it "オーナーコンポーネントを返す" do
        owner = Component.new
        item  = Item.new(owner)
        expect(item.owner).to eq owner
      end
    end
  end
end
