require_relative  '../../../spec_helper'

module RGen::InputBase
  describe ItemFactory do
    let(:active_item) do
      Class.new(Item) { build {} }
    end

    let(:passive_item) do
      Class.new(Item)
    end

    let(:target_items) do
      [active_item, passive_item]
    end

    let(:factory) do
      ItemFactory.new
    end

    describe "#active_item_factory?" do
      context "#target_itemで登録されているアイテムがactive_itemの場合" do
        it "真を返す" do
          factory.target_item = active_item
          expect(factory).to be_active_item_factory
        end
      end

      context "#target_itemで登録されているアイテムがpassive_itemの場合" do
        it "偽を返す" do
          factory.target_item = passive_item
          expect(factory).not_to be_active_item_factory
        end
      end

      context "#target_itemsで対象アイテム群が登録されている場合" do
        it "真を返す" do
          factory.target_items  = target_items
          expect(factory).to be_active_item_factory
        end
      end
    end

    describe "#passive_item_factory?" do
      context "#target_itemで登録されているアイテムがactive_itemの場合" do
        it "偽を返す" do
          factory.target_item = active_item
          expect(factory).not_to be_passive_item_factory
        end
      end

      context "#target_itemで登録されているアイテムがpassive_itemの場合" do
        it "真を返す" do
          factory.target_item = passive_item
          expect(factory).to be_passive_item_factory
        end
      end

      context "#target_itemsで対象アイテム群が登録されている場合" do
        it "偽を返す" do
          factory.target_items  = target_items
          expect(factory).not_to be_passive_item_factory
        end
      end
    end
  end
end
