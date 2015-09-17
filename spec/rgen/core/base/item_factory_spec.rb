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
      context "value_item_factoryのとき" do
        let(:test_factory) do
          ItemFactory.new(:value_item_factory)
        end

        let(:item) do
          item  = test_factory.create(owner)
        end

        before do
          test_factory.register(item_a)
          test_factory.register(item_b)
        end

        it "#registerで一番に登録されたItemオブジェクトを生成する" do
          expect(item).to be_kind_of(item_a)
        end
      end

      context "list_item_factoryのとき" do
        let(:test_factory) do
          f = Class.new(ItemFactory) do
            def select_target_item(arg)
              @target_items[arg]
            end
          end
          f.new(:list_item_factory)
        end

        let(:item) do
          item  = test_factory.create(owner, :item_b)
        end

        before do
          test_factory.register(item_a, :item_a)
          test_factory.register(item_b, :item_b)
        end

        it "#select_target_itemで選択されたItemオブジェクトを生成する" do
          expect(item).to be_kind_of(item_b)
        end
      end
    end
  end
end
