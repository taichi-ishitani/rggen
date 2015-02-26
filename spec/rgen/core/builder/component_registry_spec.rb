require_relative  '../../../spec_helper'

module RGen::Builder
  describe ComponentRegistry do
    let(:builder) do
      Builder.new
    end

    let(:registry_name) do
      :foo
    end

    let(:component_registry) do
      ComponentRegistry.new(builder, registry_name)
    end

    let(:component_entries) do
      component_registry.instance_variable_get(:@entries)
    end

    let(:categories) do
      builder.categories
    end

    let(:loader_base) do
      RGen::InputBase::Loader
    end

    let(:loaders) do
      component_registry.instance_variable_get(:@loaders)
    end

    def match_loader(base, *support_types)
      have_attributes(superclass: base, support_types: support_types)
    end

    describe "#register_component" do
      it "コンポーネントの登録を行う" do
        component_registry.register_component(:register_block) do
          component_class   RGen::RegisterMap::RegisterBlock::RegisterBlock
          component_factory RGen::RegisterMap::RegisterBlock::Factory
          item_base         RGen::RegisterMap::RegisterBlock::Item
          item_factory      RGen::RegisterMap::RegisterBlock::ItemFactory
        end

        expect(component_entries.last).to have_attributes(
          component_class:   RGen::RegisterMap::RegisterBlock::RegisterBlock,
          component_factory: RGen::RegisterMap::RegisterBlock::Factory,
          item_base:         RGen::RegisterMap::RegisterBlock::Item,
          item_factory:      RGen::RegisterMap::RegisterBlock::ItemFactory
        )
      end

      context "アイテムの設定が行われた場合" do
        it "生成されたエントリのカテゴリへの登録は行わない" do
          categories.each_value do |category|
            expect(category).not_to receive(:append_item_registry)
          end

          component_registry.register_component do
            component_class   RGen::RegisterMap::RegisterMap
            component_factory RGen::RegisterMap::Factory
          end
        end
      end

      context "アイテムの設定が行われ、" do
        context "引数で所属するカテゴリの指定がある場合" do
          it "指定されたカテゴリに、生成したエントリのアイテムレジストリを追加する" do
            categories.each do |name, category|
              if name == :register_block
                allow(category).to receive(:append_item_registry)
              else
                expect(category).not_to receive(:append_item_registry)
              end
            end

            item_registry = nil
            component_registry.register_component(:register_block) do
              component_class   RGen::RegisterMap::RegisterBlock::RegisterBlock
              component_factory RGen::RegisterMap::RegisterBlock::Factory
              item_base         RGen::RegisterMap::RegisterBlock::Item
              item_factory      RGen::RegisterMap::RegisterBlock::ItemFactory
              item_registry = self.item_registry
            end

            expect(categories[:register_block]).to have_received(:append_item_registry).with(registry_name, item_registry)
          end
        end

        context "引数で所属するカテゴリの指定がない場合" do
          it "指定されたカテゴリに、生成したエントリのアイテムレジストリを追加する" do
            categories.each_value do |category|
              allow(category).to receive(:append_item_registry)
            end

            item_registry = nil
            component_registry.register_component do
              component_class   RGen::Configuration::Configuration
              component_factory RGen::Configuration::Factory
              item_base         RGen::Configuration::Item
              item_factory      RGen::Configuration::ItemFactory
              item_registry = self.item_registry
            end

            categories.each_value do |category|
              expect(category).to have_received(:append_item_registry).with(registry_name, item_registry)
            end
          end
        end
      end
    end

    describe "#register_loader" do
      before do
        component_registry.register_component do
          component_class   RGen::Configuration::Configuration
          component_factory RGen::Configuration::Factory
          item_base         RGen::Configuration::Item
          item_factory      RGen::Configuration::ItemFactory
        end
      end

      let(:support_types) do
        [:yml, :yaml]
      end

      context "#loader_baseでローダのベースクラスが登録されている場合" do
        before do
          component_registry.loader_base(loader_base)
        end

        it "引数で与えられたファイルタイプをサポートするローダを定義し、登録する" do
          component_registry.register_loader(*support_types) do
            def loader(file)
            end
          end

          expect(loaders.last).to match_loader(loader_base, *support_types)
        end
      end

      context "#loader_baseでローダのベースクラスが登録されていない場合" do
        it "ローダの登録は行わない" do
          expect{
            component_registry.register_loader(*support_types) do
              def loader(file)
              end
            end
          }.not_to change{loaders.size}
        end
      end
    end
  end
end
