require_relative  '../../spec_helper'

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

    describe "#entry" do
      it "コンポーネントの登録を行う" do
        component_store.entry(:register_block) do
          component_class   RGen::Base::Component
          component_factory RGen::Base::ComponentFactory
          item_base         RGen::Base::Item
          item_factory      RGen::Base::ItemFactory
        end

        entry = component_entries.last
        aggregate_failures do
          expect(entry.component_class  ).to be RGen::Base::Component
          expect(entry.component_factory).to be RGen::Base::ComponentFactory
          expect(entry.item_base        ).to be RGen::Base::Item
          expect(entry.item_factory     ).to be RGen::Base::ItemFactory
        end
      end

      context "アイテムの設定が行われなかった場合" do
        it "生成されたエントリのカテゴリへの登録は行わない" do
          categories.each_value do |category|
            expect(category).not_to receive(:add_item_store)
          end

          component_store.entry do
            component_class   RGen::Base::Component
            component_factory RGen::Base::ComponentFactory
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
              component_class   RGen::Base::Component
              component_factory RGen::Base::ComponentFactory
              item_base         RGen::Base::Item
              item_factory      RGen::Base::ItemFactory
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
              component_class   RGen::Base::Component
              component_factory RGen::Base::ComponentFactory
              item_base         RGen::Base::Item
              item_factory      RGen::Base::ItemFactory
              item_store  = self.item_store
            end

            categories.each_value do |category|
              expect(category).to have_received(:add_item_store).with(registry_name, item_store)
            end
          end
        end
      end
    end

    describe "#build_factory" do
      before do
        classes = factory_classes

        component_store.entry do
          component_class   RGen::Base::Component

          component_factory RGen::Base::ComponentFactory do
            classes << self
          end
        end
        component_store.entry(:register_block) do
          component_class   RGen::Base::Component
          component_factory RGen::Base::ComponentFactory do
            classes << self
          end
        end
        component_store.entry(:register) do
          component_class   RGen::Base::Component
          component_factory RGen::Base::ComponentFactory do
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
    end
  end
end
