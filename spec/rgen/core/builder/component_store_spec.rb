require_relative  '../../../spec_helper'

module RGen::Builder
  describe ComponentStore do
    let(:builder) do
      Builder.new
    end

    let(:registry_name) do
      :foo
    end

    let(:component_store) do
      ComponentStore.new(builder, registry_name)
    end

    let(:component_entries) do
      component_store.instance_variable_get(:@entries)
    end

    let(:categories) do
      builder.categories
    end

    let(:loader_base) do
      RGen::InputBase::Loader
    end

    let(:loaders) do
      component_store.instance_variable_get(:@loaders)
    end

    describe "#entry" do
      it "コンポーネントの登録を行う" do
        component_store.entry(:register_block) do
          component_class   RGen::InputBase::Component
          component_factory RGen::InputBase::ComponentFactory
          item_base         RGen::InputBase::Item
          item_factory      RGen::InputBase::ItemFactory
        end

        entry = component_entries.last
        aggregate_failures do
          expect(entry.component_class  ).to be RGen::InputBase::Component
          expect(entry.component_factory).to be RGen::InputBase::ComponentFactory
          expect(entry.item_base        ).to be RGen::InputBase::Item
          expect(entry.item_factory     ).to be RGen::InputBase::ItemFactory
        end
      end

      context "アイテムの設定が行われなかった場合" do
        it "生成されたエントリのカテゴリへの登録は行わない" do
          categories.each_value do |category|
            expect(category).not_to receive(:add_item_store)
          end

          component_store.entry do
            component_class   RGen::InputBase::Component
            component_factory RGen::InputBase::ComponentFactory
          end
        end
      end

      context "アイテムの設定が行われ、" do
        context "引数で所属するカテゴリの指定がある場合" do
          it "指定されたカテゴリに、生成したエントリのアイテムレジストリを追加する" do
            categories.each do |name, category|
              if name == :register_block
                allow(category).to receive(:add_item_store)
              else
                expect(category).not_to receive(:add_item_store)
              end
            end

            item_store = nil
            component_store.entry(:register_block) do
              component_class   RGen::InputBase::Component
              component_factory RGen::InputBase::ComponentFactory
              item_base         RGen::InputBase::Item
              item_factory      RGen::InputBase::ItemFactory
              item_store = self.item_store
            end

            expect(categories[:register_block]).to have_received(:add_item_store).with(registry_name, item_store)
          end
        end

        context "引数で所属するカテゴリの指定がない場合" do
          it "指定されたカテゴリに、生成したエントリのアイテムレジストリを追加する" do
            categories.each_value do |category|
              allow(category).to receive(:add_item_store)
            end

            item_store = nil
            component_store.entry do
              component_class   RGen::InputBase::Component
              component_factory RGen::InputBase::ComponentFactory
              item_base         RGen::InputBase::Item
              item_factory      RGen::Configuration::ItemFactory
              item_store  = self.item_store
            end

            categories.each_value do |category|
              expect(category).to have_received(:add_item_store).with(registry_name, item_store)
            end
          end
        end
      end
    end

    describe "#define_loader" do
      before do
        component_store.entry do
          component_class   RGen::InputBase::Component
          component_factory RGen::InputBase::ComponentFactory
          item_base         RGen::InputBase::Item
          item_factory      RGen::Configuration::ItemFactory
        end
      end

      let(:supported_types) do
        [:yml, :yaml]
      end

      context "#loader_baseでローダのベースクラスが登録されている場合" do
        before do
          component_store.loader_base(loader_base)
        end

        it "引数で与えられたファイルタイプをサポートするローダを定義し、登録する" do
          component_store.define_loader(supported_types) do
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
            component_store.define_loader(supported_types) do
              def loader(file)
              end
            end
          }.not_to change{loaders.size}
        end
      end
    end

    describe "#build_factory" do
      before do
        classes = factory_classes

        component_store.loader_base(loader_base)
        component_store.entry do
          component_class   RGen::InputBase::Component

          component_factory RGen::InputBase::ComponentFactory do
            classes << self
          end
        end
        component_store.entry(:register_block) do
          component_class   RGen::InputBase::Component
          component_factory RGen::InputBase::ComponentFactory do
            classes << self
          end
        end
        component_store.entry(:register) do
          component_class   RGen::InputBase::Component
          component_factory RGen::InputBase::ComponentFactory do
            classes << self
          end
        end
      end

      let(:factory_classes) do
        []
      end

      let(:built_factories) do
        factory   = component_store.build_factory
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
        component_store.build_factory
      end

      specify "生成されたファクトリは登録順に親子関係をもつ" do
        factory_classes.each_with_index do |f, i|
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
            component_store.define_loader(type) do
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
