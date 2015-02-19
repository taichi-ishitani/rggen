require_relative  '../../../spec_helper'

module RGen::Builder
  describe ComponentEntry do
    let(:component_class) do
      RGen::Configuration::Configuration
    end

    let(:component_factory) do
      RGen::Configuration::Factory
    end

    let(:item_class) do
      RGen::Configuration::Item
    end

    let(:item_factory) do
      RGen::Configuration::ItemFactory
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
      context "item, item_factoryを含まない時" do
        let(:component_entry) do
          ComponentEntry.new(component_class, component_factory)
        end

        it "アイテムを含まないコンポーネントオブジェクトを生成するファクトリを返す" do
          expect(component).to be_kind_of(component_class)
          expect(component.fields).to be_empty
        end
      end

      context "item, item_factoryを含む時" do
        let(:component_entry) do
          ComponentEntry.new(component_class, component_factory, item_class, item_factory)
        end

        before do
          [:foo, :bar].each do |item_name|
            component_entry.item_registry.register_item(item_name) do
              define_field item_name, default: item_name
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
