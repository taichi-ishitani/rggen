require_relative  '../../spec_helper'

module RgGen::Builder
  describe SimpleItemEntry do
    let(:item_base) do
      RgGen::InputBase::Item
    end

    let(:factory) do
      RgGen::InputBase::ItemFactory
    end

    let(:shared_context) do
      Object.new
    end

    let(:component) do
      RgGen::InputBase::Component.new(nil)
    end

    def item_entry(context, &body)
      SimpleItemEntry.new(item_base, factory, context, &body)
    end

    describe "#initialize" do
      it "与えたベースアイテムクラスを親クラスとして、アイテムクラスを定義する" do
        expect(item_entry(nil).item_class.superclass).to be item_base
      end

      context "ブロックが与えられた場合" do
        it "ブロックをアイテムクラスのコンテキストで実行する" do
          entry = item_entry(nil) do
            def foo; end
          end
          expect(entry.item_class).to be_method_defined(:foo)
        end
      end

      context "共有コンテキストが与えられた場合" do
        it "アイテムクラスに与えた共有コンテキストを参照する#shared_contextを定義する" do
          item  = item_entry(shared_context).item_class.new(component)
          expect(item.send(:shared_context)).to eql shared_context
        end
      end
    end

    describe "#build_factory" do
      let(:entry) do
        item_entry(nil)
      end

      let(:item) do
        f = entry.build_factory
        f.create(component)
      end

      it "定義したアイテムクラスを生成するファクトリオブジェクトを返す" do
        expect(item).to be_instance_of(entry.item_class)
      end
    end
  end
end
