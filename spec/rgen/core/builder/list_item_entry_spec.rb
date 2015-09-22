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
      before do
        list_item_entry.register_list_item(:foo) do
          field :foo
        end
      end

      it "#item_baseを親クラスとしてアイテムクラスを定義し、与えたアイテム名で登録する" do
        expect(items[:foo]).to have_attributes(
          superclass: list_item_entry.item_base,
          fields:     match([:foo])
        )
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

      specify "ファクトリオブジェクトはリストアイテム型" do
        expect(factory.instance_variable_get(:@factory_type)).to eq :list_item_factory
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
