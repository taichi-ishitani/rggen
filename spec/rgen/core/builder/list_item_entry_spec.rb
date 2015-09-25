require_relative  '../../../spec_helper'

module RGen::Builder
  describe ListItemEntry do
    let(:item_base) do
      RGen::InputBase::Item
    end

    let(:factory_base) do
      RGen::InputBase::ItemFactory
    end

    let(:list_item_entry) do
      ListItemEntry.new(item_base, factory_base)
    end

    let(:items) do
      list_item_entry.instance_variable_get(:@items)
    end

    let(:shared_context) do
      Object.new
    end

    describe "#initialize" do
      context "ブロックが与えられた場合" do
        specify "ブロックを自身のコンテキストで実行する" do
          entry1  = nil
          entry2  = ListItemEntry.new(item_base, factory_base) do
            entry1  = self
          end

          expect(entry1).to eql entry2
        end
      end

      context "コンテキストオブジェクトが与えられたとき" do
        specify "与えられたコンテキストオブジェクトをブロック内で参照できる" do
          actual_context = nil
          ListItemEntry.new(item_base, factory_base, shared_context) do |context|
            actual_context  = context
          end

          expect(actual_context).to eql shared_context
        end
      end
    end

    describe "#item_base" do
      it "生成時に与えたitem_baseを親クラスとするベースアイテムクラスを返す" do
        expect(list_item_entry.item_base.superclass).to be item_base
      end

      context "ブロックを与えたとき" do
        before do
          list_item_entry.item_base do
            def foo
            end
          end
        end

        it "ブロックをベースアイテムクラスのコンテキストで実行する" do
          expect(list_item_entry.item_base).to be_method_defined(:foo)
        end
      end
    end

    describe "#factory" do
      it "生成時に与えたfactory_baseを親クラスとするアイテムファクトリクラスを返す" do
        expect(list_item_entry.factory.superclass).to be factory_base
      end

      context "ブロックを与えたとき" do
        before do
          list_item_entry.factory do
            def foo
            end
          end
        end

        it "ブロックをアイテムファクトリクラスのコンテキストで実行する" do
          expect(list_item_entry.factory).to be_method_defined(:foo)
        end
      end
    end

    describe "#register_list_item" do
      it "#item_baseを親クラスとしてアイテムクラスを定義し、与えたアイテム名で登録する" do
        list_item_entry.register_list_item(:foo) do
          field :foo
        end

        expect(items[:foo]).to have_attributes(
          superclass: list_item_entry.item_base,
          fields:     match([:foo])
        )
      end

      context "コンテキストオブジェクトが与えられたとき" do
        specify "与えられたコンテキストオブジェクトはブロック内で参照できる" do
          actual_context  = nil
          list_item_entry.register_list_item(:foo, shared_context) do |context|
            actual_context  = context
          end

          expect(actual_context).to be shared_context
        end
      end
    end

    describe "#build_factory" do
      before do
        list_item_entry.factory do
          def select_target_item(arg)
            fail unless @target_items.key?(arg)
            @target_items[arg]
          end
        end

        list_item_entry.register_list_item(:foo) do
        end
        list_item_entry.register_list_item(:bar) do
        end
        list_item_entry.register_list_item(:baz) do
        end
        list_item_entry.register_list_item(:qux) do
        end

        list_item_entry.enable([:qux, :baz])
        list_item_entry.enable(:foo)
      end

      let(:factory) do
        list_item_entry.build_factory
      end

      it "アイテムファクトリオブジェクトを返す" do
        expect(factory).to be_kind_of list_item_entry.factory
      end

      specify "ファクトリオブジェクトは#enableで有効になったアイテムを生成できる" do
        expect(factory.create(nil, :foo)).to be_kind_of items[:foo]
        expect(factory.create(nil, :baz)).to be_kind_of items[:baz]
        expect(factory.create(nil, :qux)).to be_kind_of items[:qux]
      end

      specify "ファクトリオブジェクトは#enableで有効にされなかったアイテムは生成できない" do
        expect {factory.create(nil, :bar)}.to raise_error RuntimeError
      end
    end
  end
end
