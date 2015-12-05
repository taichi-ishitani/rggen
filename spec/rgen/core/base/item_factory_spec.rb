require_relative  '../../../spec_helper'

module RGen::Base
  describe ItemFactory do
    let(:item_a) do
      Class.new(Item)
    end

    let(:item_b) do
      Class.new(Item)
    end

    let(:owner) do
      Component.new(nil)
    end

    describe "#create" do
      context "target_items=で対象アイテムクラス群が登録されているとき" do
        let(:test_factory) do
          f = Class.new(ItemFactory) do
            def select_target_item(arg)
              @target_items[arg]
            end
          end
          f.new
        end

        before do
          test_factory.target_items = {item_a: item_a}
          test_factory.target_item  = item_b
        end

        context "#select_target_itemがクラスを返す場合" do
          let(:item) do
            item  = test_factory.create(owner, :item_a)
          end

          it "#select_target_itemで選択されたアイテムオブジェクトを生成する" do
            expect(item).to be_kind_of(item_a)
          end
        end

        context "#target_item=で対象アイテムクラスが登録されていて、#select_target_itemがクラスを返さない場合" do
          let(:item) do
            item  = test_factory.create(owner, :item_b)
          end

          it "#target_item=で登録されたアイテムオブジェクトを生成する" do
            expect(item).to be_kind_of(item_b)
          end
        end
      end

      context "target_items=で対象アイテムクラス群が登録されていないとき" do
        let(:test_factory) do
          ItemFactory.new
        end

        let(:item) do
          test_factory.create(owner)
        end

        before do
          test_factory.target_item  = item_a
        end

        it "#target_item=で登録されたItemオブジェクトを生成する" do
          expect(item).to be_kind_of(item_a)
        end
      end
    end
  end
end
