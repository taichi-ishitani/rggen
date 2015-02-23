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

    before do
      item_registries.each do |name, registry|
        category.append_item_registry(name, registry)
      end
    end

    describe "#register_item" do
      it "引数で与えた名前で、ブロック内で指定した対象アイテムの定義を行う" do
        expect(item_registries[:configuration]).to receive(:register_item).with(:foo).and_call_original
        expect(item_registries[:configuration]).to receive(:register_item).with(:bar).and_call_original
        expect(item_registries[:register_map ]).to receive(:register_item).with(:foo).and_call_original

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
  end
end
