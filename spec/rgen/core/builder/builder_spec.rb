require_relative  '../../../spec_helper'

module RGen::Builder
  describe Builder do
    let(:builder) do
      Builder.new
    end

    let(:categories) do
      builder.categories
    end

    let(:registries) do
      builder.instance_variable_get(:@registries)
    end

    it "4種類のカテゴリを持つ" do
      expect(categories).to match(
        global:         be_kind_of(Category),
        register_block: be_kind_of(Category),
        register:       be_kind_of(Category),
        bit_field:      be_kind_of(Category)
      )
    end

    describe "#component_registry" do
      it "コンポーネントエントリを生成し、引数で与えられた名前で登録する" do
        registry  = nil
        builder.component_registry(:register_map) do
          register_component do
            component_class   RGen::RegisterMap::RegisterMap
            component_factory RGen::RegisterMap::Factory
          end
          register_component(:register_block) do
            component_class   RGen::RegisterMap::RegisterBlock::RegisterBlock
            component_factory RGen::RegisterMap::RegisterBlock::Factory
            item_base         RGen::RegisterMap::RegisterBlock::Item
            item_factory      RGen::RegisterMap::RegisterBlock::ItemFactory
          end
          registry  = self
        end

        expect(registries[:register_map]).to eql registry
      end
    end

    describe "#register_loader" do
      before do
        builder.component_registry(:register_map) do
          loader_base RGen::InputBase::Loader
          register_component do
            component_class   RGen::RegisterMap::RegisterMap
            component_factory RGen::RegisterMap::Factory
          end
        end
      end

      let(:support_types) do
        [:xls, :xlsx]
      end

      it "引数で与えられた名前のコンポーネントレジストリの#register_loader、ローダの登録を行う" do
        expect(registries[:register_map]).to receive(:register_loader).with(support_types).and_call_original
        builder.register_loader(:register_map, support_types) do
        end
      end
    end

    describe "#build_factory" do
      before do
        builder.component_registry(:register_map) do
          register_component do
            component_class   RGen::RegisterMap::RegisterMap
            component_factory RGen::RegisterMap::Factory
          end
          register_component(:register_block) do
            component_class   RGen::RegisterMap::RegisterBlock::RegisterBlock
            component_factory RGen::RegisterMap::RegisterBlock::Factory
            item_base         RGen::RegisterMap::RegisterBlock::Item
            item_factory      RGen::RegisterMap::RegisterBlock::ItemFactory
          end
        end
      end

      it "引数で与えられた名前のコンポーネントレジストリの#build_factoryを呼び出して、ファクトリの生成を行う" do
        expect(registries[:register_map]).to receive(:build_factory).and_call_original
        builder.build_factory(:register_map)
      end
    end

    describe "#define_value_item" do
      before do
        builder.component_registry(:configuration) do
          register_component do
            component_class   RGen::Configuration::Configuration
            component_factory RGen::Configuration::Factory
            item_base         RGen::Configuration::Item
            item_factory      RGen::Configuration::ItemFactory
          end
        end
      end

      let(:item_name) do
        :foo
      end

      it "引数で与えられた名前のカテゴリの#define_value_itemを呼び出して、アイテムの登録を行う" do
        expect(categories[:global]).to receive(:define_value_item).with(item_name).and_call_original
        builder.define_value_item(:global, item_name) do
          configuration do
          end
        end
      end
    end

    describe "#define_list_item" do
      before do
        builder.component_registry(:configuration) do
          register_component do
            component_class   RGen::Configuration::Configuration
            component_factory RGen::Configuration::Factory
            item_base         RGen::Configuration::Item
            item_factory      RGen::Configuration::ItemFactory
          end
        end
      end

      let(:list_name) do
        :foo
      end

      let(:item_name) do
        :bar
      end

      it "引数で与えられた名前のカテゴリの#define_list_itemを呼び出して、アイテムの登録を行う" do
        expect(categories[:global]).to receive(:define_list_item).with(list_name, nil      ).and_call_original
        expect(categories[:global]).to receive(:define_list_item).with(list_name, item_name).and_call_original
        builder.define_list_item(:global, list_name) do
          configuration do
          end
        end
        builder.define_list_item(:global, list_name, item_name) do
          configuration do
          end
        end
      end
    end


    describe "#enable" do
      before do
        builder.component_registry(:configuration) do
          register_component do
            component_class   RGen::Configuration::Configuration
            component_factory RGen::Configuration::Factory
            item_base         RGen::Configuration::Item
            item_factory      RGen::Configuration::ItemFactory
          end
        end

        [:baz, :qux].each do |item_name|
          builder.define_value_item(:global, item_name) do
            configuration do
            end
          end
        end

        [:baz, :qux].each do |item_name|
          builder.define_list_item(:global, item_name) do
            configuration do
            end
          end
        end
      end

      it "引数で与えられた名前のカテゴリの#enableを呼び出して、アイテムの有効化を行う" do
        expect(categories[:global]).to receive(:enable).with([:foo, :bar]).and_call_original
        expect(categories[:global]).to receive(:enable).with(:qux).and_call_original
        expect(categories[:global]).to receive(:enable).with(:qux, :foo).and_call_original
        expect(categories[:global]).to receive(:enable).with(:qux, [:bar, :baz]).and_call_original
        builder.enable(:global, [:foo, :bar])
        builder.enable(:global, :qux)
        builder.enable(:global, :qux, :foo)
        builder.enable(:global, :qux, [:bar, :baz])
      end
    end
  end
end
