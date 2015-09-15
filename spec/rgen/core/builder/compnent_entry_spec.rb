require_relative  '../../../spec_helper'

module RGen::Builder
  describe ComponentEntry do
    let(:component_class) do
      RGen::Configuration::Configuration
    end

    let(:component_factory) do
      RGen::Configuration::Factory
    end

    let(:item_base) do
      RGen::Configuration::Item
    end

    let(:item_factory) do
      RGen::Configuration::ItemFactory
    end

    let(:component_entry) do
      entry = ComponentEntry.new
      entry.component_class(component_class)
      entry.component_factory(component_factory)
      entry
    end

    let(:factory) do
      f = component_entry.build_factory
      f.root_factory
      f
    end

    let(:component) do
      factory.create
    end

    describe "#build_factory" do
      context "アイテムを持たないとき" do
        it "アイテムを含まないコンポーネントオブジェクトを生成するファクトリを返す" do
          expect(component).to be_kind_of(component_class)
          expect(component.fields).to be_empty
        end
      end

      context "アイテムを持つとき" do
        before do
          component_entry.item_base(item_base)
          component_entry.item_factory(item_factory)
          [:foo, :bar].each do |item_name|
            component_entry.item_registry.register_value_item(item_name) do
              field item_name, default: item_name
            end
            component_entry.item_registry.enable(item_name)
          end
        end

        it "有効になったアイテムを含むコンポーネントオブジェクトを生成するファクトリを返す" do
          expect(component).to be_kind_of(component_class)
          expect(component.fields).to match([:foo, :bar])
        end
      end
    end
  end
end
