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
            expect(category).not_to receive(:append_item_store)
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
                allow(category).to receive(:append_item_store)
              else
                expect(category).not_to receive(:append_item_store)
              end
            end

            item_store = nil
            component_registry.register_component(:register_block) do
              component_class   RGen::RegisterMap::RegisterBlock::RegisterBlock
              component_factory RGen::RegisterMap::RegisterBlock::Factory
              item_base         RGen::RegisterMap::RegisterBlock::Item
              item_factory      RGen::RegisterMap::RegisterBlock::ItemFactory
              item_store = self.item_store
            end

            expect(categories[:register_block]).to have_received(:append_item_store).with(registry_name, item_store)
          end
        end

        context "引数で所属するカテゴリの指定がない場合" do
          it "指定されたカテゴリに、生成したエントリのアイテムレジストリを追加する" do
            categories.each_value do |category|
              allow(category).to receive(:append_item_store)
            end

            item_store = nil
            component_registry.register_component do
              component_class   RGen::Configuration::Configuration
              component_factory RGen::Configuration::Factory
              item_base         RGen::Configuration::Item
              item_factory      RGen::Configuration::ItemFactory
              item_store  = self.item_store
            end

            categories.each_value do |category|
              expect(category).to have_received(:append_item_store).with(registry_name, item_store)
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

      let(:supported_types) do
        [:yml, :yaml]
      end

      context "#loader_baseでローダのベースクラスが登録されている場合" do
        before do
          component_registry.loader_base(loader_base)
        end

        it "引数で与えられたファイルタイプをサポートするローダを定義し、登録する" do
          component_registry.register_loader(supported_types) do
            def loader(file)
            end
          end

          expect(loaders.last).to be < loader_base
          expect(loaders.last.instance_variable_get(:@supported_types)).to match supported_types
        end
      end

      context "#loader_baseでローダのベースクラスが登録されていない場合" do
        it "ローダの登録は行わない" do
          expect{
            component_registry.register_loader(supported_types) do
              def loader(file)
              end
            end
          }.not_to change{loaders.size}
        end
      end
    end

    describe "#build_factory" do
      before do
        component_registry.loader_base(loader_base)
        component_registry.register_component do
          component_class   RGen::RegisterMap::RegisterMap
          component_factory RGen::RegisterMap::Factory
        end
        component_registry.register_component(:register_block) do
          component_class   RGen::RegisterMap::RegisterBlock::RegisterBlock
          component_factory RGen::RegisterMap::RegisterBlock::Factory
          item_base         RGen::RegisterMap::RegisterBlock::Item
          item_factory      RGen::RegisterMap::RegisterBlock::ItemFactory
        end
        component_registry.register_component(:register) do
          component_class   RGen::RegisterMap::Register::Register
          component_factory RGen::RegisterMap::Register::Factory
          item_base         RGen::RegisterMap::Register::Item
          item_factory      RGen::RegisterMap::Register::ItemFactory
        end
        categories[:register_block].define_value_item(:bar) do
          foo do
          end
        end
        categories[:register].define_value_item(:bar) do
          foo do
          end
        end
        categories[:register_block].enable(:bar)
        categories[:register].enable(:bar)
      end

      let(:built_factories) do
        factory   = component_registry.build_factory
        factories = [factory]
        loop do
          factory = factory.instance_variable_get(:@child_factory)
          break unless factory
          factories << factory
        end
        factories
      end

      it "登録された順にComponentEntry#build_factoryを呼び出して、ファクトリを生成する" do
        component_entries.each do |entry|
          expect(entry).to receive(:build_factory).and_call_original.ordered
        end
        component_registry.build_factory
      end

      specify "生成されたファクトリは登録順に親子関係をもつ" do
        [
          RGen::RegisterMap::Factory,
          RGen::RegisterMap::RegisterBlock::Factory,
          RGen::RegisterMap::Register::Factory
        ].each_with_index do |f, i|
          expect(built_factories[i]).to be_kind_of(f)
        end
      end

      specify "1番目のファクトリはルートファクトリ" do
        expect(built_factories.first.instance_variable_get(:@root_factory)).to be_truthy
      end

      specify "2番目以降はルートファクトリではない" do
        built_factories.drop(1).each do |f|
          expect(f.instance_variable_get(:@root_factory)).to be_falsey
        end
      end

      context "ローダが登録されているとき" do
        before do
          [:xls, :csv].each do |type|
            component_registry.register_loader(type) do
              def loader(file)
              end
            end
          end
        end

        specify "ルートファクトリのみローダを持つ" do
          built_factories.each_with_index do |f, i|
            if i == 0
              expect(f.instance_variable_get(:@loaders)).to match loaders
            else
              expect(f.instance_variable_get(:@loaders)).not_to match loaders
            end
          end
        end
      end
    end
  end
end
