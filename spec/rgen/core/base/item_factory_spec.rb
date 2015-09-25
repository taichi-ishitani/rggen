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
      Component.new
    end

    describe "#create" do
      context "#target_item=で対象アイテムクラスが登録された場合" do
        let(:test_factory) do
          ItemFactory.new
        end

        let(:item) do
          test_factory.create(owner)
        end

        before do
          test_factory.target_item  = item_a
        end

        it "登録されたItemオブジェクトを生成する" do
          expect(item).to be_kind_of(item_a)
        end
      end

      context "target_items=で対象アイテムクラス群が登録された場合" do
        let(:test_factory) do
          f = Class.new(ItemFactory) do
            def select_target_item(arg)
              @target_items[arg]
            end
          end
          f.new
        end

        let(:item) do
          item  = test_factory.create(owner, :item_b)
        end

        before do
          test_factory.target_items = {item_a: item_a, item_b: item_b}
        end

        it "#select_target_itemで選択されたアイテムオブジェクトを生成する" do
          expect(item).to be_kind_of(item_b)
        end
      end
    end
  end
end
