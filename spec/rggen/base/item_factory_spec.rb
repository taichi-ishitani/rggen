require_relative  '../../spec_helper'

module RgGen::Base
  describe ItemFactory do
    let(:owner) do
      Component.new(nil)
    end

    let(:item_a) do
      Item.new(owner)
    end

    let(:item_b) do
      Item.new(owner)
    end

    let(:item_c) do
      Item.new(owner).tap { |item| allow(item).to receive(:valid?).and_return(false) }
    end

    let(:item_class_a) do
      Class.new(Item).tap { |klass| allow(klass).to receive(:new).and_return(item_a) }
    end

    let(:item_class_b) do
      Class.new(Item).tap { |klass| allow(klass).to receive(:new).and_return(item_b) }
    end

    let(:item_class_c) do
      Class.new(Item).tap { |klass| allow(klass).to receive(:new).and_return(item_c) }
    end

    let(:test_factory) do
      Class.new(ItemFactory) {
        def create(owner, *args, &block)
          create_item(owner, *args, &block)
        end

        def select_target_item(arg)
          @target_items[arg]
        end
      }.new
    end

    let(:created_items) do
      owner.items
    end

    let(:created_item) do
      created_items.first
    end

    before do
      test_factory.target_item  = item_class_a
    end

    describe "#create_item" do
      it "対象アイテムオブジェクトを生成し、Component#add_itemを呼び出して、所有者コンポーネントに生成されたアイテムを追加する" do
        expect(owner).to receive(:add_item).and_call_original
        test_factory.create(owner)
        expect(created_item).to equal item_a
      end

      it "生成したアイテムオブジェクトを引数にして、与えられたブロックを実行する" do
        expect { |b|
          test_factory.create(owner, &b)
        }.to yield_with_args(equal(item_a))
      end

      context "target_items=で対象アイテムクラス群が登録されているとき" do
        before do
          test_factory.target_items = { item_b: item_class_b }
        end

        context "#select_target_itemがクラスを返す場合" do
          it "#select_target_itemで選択されたアイテムオブジェクトを生成する" do
            test_factory.create(owner, :item_b)
            expect(created_item).to equal item_b
          end
        end

        context "#select_target_itemがクラスを返さない場合" do
          it "#target_item=で登録されたアイテムオブジェクトを生成する" do
            test_factory.create(owner, :item_c)
            expect(created_item).to equal item_a
          end
        end
      end

      context "生成したアイテムオブジェクトが有効ではない(Item#valid?がfalseを返す)場合" do
        before do
          test_factory.target_items = { item_c: item_class_c }
        end

        it "所有者コンポーネントに生成したアイテムを追加しない" do
          expect(owner).not_to receive(:add_item)
          test_factory.create(owner, :item_c)
        end

        it "与えられたブロックを実行しない" do
          expect { |b|
            test_factory.create(owner, :item_c, &b)
          }.not_to yield_control
        end
      end
    end
  end
end
