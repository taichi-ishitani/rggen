require_relative  '../../../spec_helper'

module RGen::Builder
  describe Registry do
    let(:base) do
      RGen::Base::Item
    end

    let(:factory) do
      RGen::Base::ItemFactory
    end

    let(:registry) do
      r = Registry.new
      r.base(base)
      r.factory(factory)
      r
    end

    describe "#register_item" do
      context "アイテム名とブロックが与えられたとき" do
        before do
          registry.register_item(:foo) do
            def foo
            end
          end
        end

        it "#baseで登録されたクラスを親クラスとしてクラスを定義し、アイテム名で登録する" do
          expect(registry.entries[:foo].item_class.superclass).to eql base
          expect(registry.entries[:foo].item_class).to be_method_defined(:foo)
        end

        it "#factoryで登録されたファクトリクラスを、対応するファクトリとして登録する" do
          expect(registry.entries[:foo].factory).to eql factory
        end
      end

      context "アイテム名とエントリオブジェクトが与えられたとき" do
        let(:entry) do
          Registry::Entry.new
        end

        before do
          registry.register_item(:foo, entry)
        end

        it "アイテム名でエントリオブジェクトを登録する" do
          expect(registry.entries[:foo]).to eql entry
        end
      end
    end

    describe "#enabled_factoreis" do
      before do
        [:foo, :bar, :baz].each do |name|
          registry.register_item(name) do
          end
        end
      end

      let(:enabled_factories) do
        registry.enable(:foo, :baz)
        registry.enabled_factories
      end

      let(:items) do
        enabled_factories.each_with_object({}) {|(n, f), h| h[n] = f.create(nil)}
      end

      it "#enableで有効にされたアイテムを生成するファクトリクラス一覧を返す" do
        expect(items).to match({
          foo: be_kind_of(registry.entries[:foo].item_class),
          baz: be_kind_of(registry.entries[:baz].item_class)
        })
      end
    end
  end
end
