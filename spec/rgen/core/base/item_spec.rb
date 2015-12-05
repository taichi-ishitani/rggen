require_relative  '../../../spec_helper'

module RGen::Base
  describe Item do
    describe "#owner" do
      it "オーナーコンポーネントを返す" do
        owner = Component.new(nil)
        item  = Item.new(owner)
        expect(item.owner).to eq owner
      end
    end

    describe ".define_helpers" do
      let(:item) do
        Class.new(Item)
      end

      it "特異クラスのコンテキストでブロックを実行し、ヘルパーメソッドの定義を行う" do
        item.define_helpers do
          def foo ; end
          def bar ; end
        end

        expect(item.singleton_methods(false)).to match [:foo, :bar]
      end
    end
  end
end
