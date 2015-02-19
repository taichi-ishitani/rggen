require_relative  '../../../spec_helper'

module RGen::Builder
  describe ItemRegistry do
    let(:item_base) do
      RGen::Configuration::Item
    end

    let(:item_factory) do
      RGen::Configuration::ItemFactory
    end

    let(:item_registry) do
      ItemRegistry.new(item_base, item_factory)
    end

    describe "#register_item" do
      before do
        item_registry.register_item(:foo) do
          define_field :foo
        end
      end

      let(:entry) do
        item_registry.entries[:foo]
      end

      it "#baseを親クラスとしてアイテムクラスを定義し、アイテム名で登録する" do
        expect(entry.klass).to have_attributes(
          superclass: item_registry.base,
          fields:     match([:foo])
        )
      end

      it "#factoryを対応するファクトリとして登録する" do
        expect(entry.factory).to eql item_registry.factory
      end
    end

    describe "#enabled_factoreis" do
      before do
        [:foo, :bar, :baz, :qux].each do |name|
          item_registry.register_item(name) do
          end
        end
        item_registry.enable(:foo, :baz)
        item_registry.enable(:qux)
      end

      let(:enabled_factories) do
        item_registry.enabled_factories
      end

      let(:items) do
        enabled_factories.each_with_object({}) {|(n, f), h| h[n] = f.create(nil, nil)}
      end

      it "#enableで有効にされたアイテムを生成するファクトリクラス一覧を有効にされた順で返す" do
        expect(items).to match({
          foo: be_kind_of(item_registry.entries[:foo].klass),
          baz: be_kind_of(item_registry.entries[:baz].klass),
          qux: be_kind_of(item_registry.entries[:qux].klass)
        })
      end

      context "#enableで同一アイテムが複数回有効にされた場合" do
        before do
          item_registry.enable(:qux, :foo)
        end

        specify "2回目以降の有効化を無視して、ファクトリクラス一覧を返す" do
          expect(items).to match({
            foo: be_kind_of(item_registry.entries[:foo].klass),
            baz: be_kind_of(item_registry.entries[:baz].klass),
            qux: be_kind_of(item_registry.entries[:qux].klass)
          })
        end
      end
    end
  end
end
