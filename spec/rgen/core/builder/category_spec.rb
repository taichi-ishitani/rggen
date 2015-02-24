require_relative  '../../../spec_helper'

module RGen::Builder
  describe Category do
    let(:category) do
      Category.new
    end

    let(:item_registries) do
      {
        configuration: ItemRegistry.new(
          RGen::Configuration::Item,
          RGen::Configuration::ItemFactory
        ),
        register_map: ItemRegistry.new(
          RGen::RegisterMap::BitField::Item,
          RGen::RegisterMap::BitField::ItemFactory
        )
      }
    end

    describe "#append_item_registry" do
      it "引数で与えられた名前で、アイテム登録用のメソッドと定義する" do
        expect{
          category.append_item_registry(:configuration, item_registries[:configuration])
        }.to change {
          category.respond_to?(:configuration)
        }.from(false).to(true)
      end
    end

    describe "#register_item" do
      before do
        item_registries.each do |name, registry|
          category.append_item_registry(name, registry)
        end
      end

      it "引数で与えた名前で、ブロック内で指定した対象アイテムの定義を行う" do
        expect(item_registries[:configuration]).to receive(:register_item).with(:foo)
        expect(item_registries[:configuration]).to receive(:register_item).with(:bar)
        expect(item_registries[:register_map ]).to receive(:register_item).with(:foo)

        category.register_item(:foo) do
          configuration do
            define_field :foo
          end
          register_map do
            define_field :foo
          end
        end

        category.register_item(:bar) do
          configuration do
            define_field :bar
          end
        end
      end
    end

    describe "#enable" do
      before do
        item_registries.each do |name, registry|
          category.append_item_registry(name, registry)
        end
        [:foo, :bar, :baz].each do |item_name|
          category.register_item(item_name) do
            configuration do
            end
            register_map do
            end
          end
        end
      end

      it "与えられたアイテム名を引数として、登録されたエントリの#enableを呼び出す" do
        expect(item_registries[:configuration]).to receive(:enable).with(:foo, :baz)
        expect(item_registries[:register_map ]).to receive(:enable).with(:foo, :baz)
        category.enable(:foo, :baz)
      end
    end
  end
end
