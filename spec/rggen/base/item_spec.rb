require_relative  '../../spec_helper'

module RgGen::Base
  describe Item do
    let(:owner) do
      Component.new(nil)
    end

    let(:item_class) do
      Class.new(Item)
    end

    let(:item) do
      item_class.new(owner)
    end

    describe "#owner" do
      it "オーナーコンポーネントを返す" do
        expect(item.owner).to eq owner
      end
    end

    describe ".define_helpers" do
      before do
        item_class.define_helpers do
          def foo ; end
          def bar ; end
        end
      end

      it "特異クラスのコンテキストでブロックを実行し、ヘルパーメソッドの定義を行う" do
        expect(item_class.singleton_methods(false)).to match [:foo, :bar]
      end
    end

    describe "#available?" do
      context "通常の場合" do
        it "使用可能であることを示す" do
          expect(item).to be_available
        end
      end

      context ".available?で#available?が再定義された場合" do
        before do
          item_class.available? do
            false
          end
        end

        it "available?に与えたブロックの評価結果を返す" do
          expect(item).not_to be_available
        end
      end
    end
  end
end
