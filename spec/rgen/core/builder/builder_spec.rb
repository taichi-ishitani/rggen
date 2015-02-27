require_relative  '../../../spec_helper'

module RGen::Builder
  describe Builder do
    let(:builder) do
      Builder.new
    end

    let(:registries) do
      builder.instance_variable_get(:@registries)
    end

    it "4種類のカテゴリを持つ" do
      expect(builder.categories).to match(
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
  end
end
