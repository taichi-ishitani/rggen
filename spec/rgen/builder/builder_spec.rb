require_relative  '../../spec_helper'

module RGen::Builder
  describe Builder do
    let(:builder) do
      Builder.new
    end

    let(:categories) do
      builder.categories
    end

    let(:stores) do
      builder.instance_variable_get(:@stores)
    end

    it "4種類のカテゴリを持つ" do
      expect(categories).to match(
        global:         be_kind_of(Category),
        register_block: be_kind_of(Category),
        register:       be_kind_of(Category),
        bit_field:      be_kind_of(Category)
      )
    end

    describe "#input_component_store" do
      it "入力コンポーネントエントリを生成し、引数で与えられた名前で登録する" do
        store = nil
        builder.input_component_store(:register_map) do
          entry do
            component_class   RGen::InputBase::Component
            component_factory RGen::InputBase::ComponentFactory
          end
          entry(:register_block) do
            component_class   RGen::InputBase::Component
            component_factory RGen::InputBase::ComponentFactory
            item_base         RGen::InputBase::Item
            item_factory      RGen::InputBase::ItemFactory
          end
          store = self
        end

        expect(store                ).to be_kind_of(InputComponentStore)
        expect(stores[:register_map]).to be store
      end
    end

    describe "#output_component_store" do
      it "出力コンポーネントエントリを生成し、引数で与えられた名前で登録する" do
        store = nil
        builder.output_component_store(:rtl) do
          entry do
            component_class   RGen::Base::Component
            component_factory RGen::Base::ComponentFactory
            item_base         RGen::Base::Item
            item_factory      RGen::Base::ItemFactory
          end
          store = self
        end

        expect(store       ).to be_kind_of(OutputComponentStore)
        expect(stores[:rtl]).to be store
      end
    end

    describe "#stored_output_components" do
      it "#output_component_storeで登録されて出力コンポーネントの一覧を返す" do
        expect {
          builder.input_component_store(:configuration) {}
        }.not_to change { builder.stored_output_components }
        expect {
          builder.output_component_store(:rtl) {}
        }.to change { builder.stored_output_components }.from(match([])).to(match([:rtl]))
        expect {
          builder.input_component_store(:register_map) {}
        }.not_to change { builder.stored_output_components }
        expect {
          builder.output_component_store(:ral) {}
        }.to change { builder.stored_output_components }.from(match([:rtl])).to(match([:rtl, :ral]))
        expect {
          builder.output_component_store(:rtl) {}
        }.not_to change { builder.stored_output_components }
      end
    end

    describe "#define_loader" do
      before do
        builder.input_component_store(:register_map) do
          loader_base RGen::InputBase::Loader
          entry do
            component_class   RGen::InputBase::Component
            component_factory RGen::InputBase::ComponentFactory
          end
        end
      end

      let(:support_types) do
        [:xls, :xlsx]
      end

      it "引数で与えられた名前のコンポーネントレジストリの#define_loader、ローダの登録を行う" do
        expect(stores[:register_map]).to receive(:define_loader).with(support_types).and_call_original
        builder.define_loader(:register_map, support_types) do
        end
      end

      context "指定したコンポーネントが存在しない場合" do
        it "RGen::Builderエラーを発生させる" do
          expect {
            builder.define_loader(:foo, support_types) {}
          }.to raise_error RGen::BuilderError, "unknown component: foo"
        end
      end
    end

    describe "#build_factory" do
      before do
        builder.input_component_store(:register_map) do
          entry do
            component_class   RGen::InputBase::Component
            component_factory RGen::InputBase::ComponentFactory
          end
          entry(:register_block) do
            component_class   RGen::InputBase::Component
            component_factory RGen::InputBase::ComponentFactory
            item_base         RGen::InputBase::Item
            item_factory      RGen::InputBase::ItemFactory
          end
        end
      end

      it "引数で与えられた名前のコンポーネントレジストリの#build_factoryを呼び出して、ファクトリの生成を行う" do
        expect(stores[:register_map]).to receive(:build_factory).and_call_original
        builder.build_factory(:register_map)
      end

      context "指定したコンポーネントが存在しない場合" do
        it "RGen::Builderエラーを発生させる" do
          expect {
            builder.build_factory(:foo)
          }.to raise_error RGen::BuilderError, "unknown component: foo"
        end
      end
    end

    describe "#define_simple_item" do
      before do
        builder.input_component_store(:configuration) do
          entry do
            component_class   RGen::InputBase::Component
            component_factory RGen::InputBase::ComponentFactory
            item_base         RGen::InputBase::Item
            item_factory      RGen::InputBase::ItemFactory
          end
        end
      end

      let(:item_name) do
        :foo
      end

      it "引数で与えられた名前のカテゴリの#define_simple_item、アイテムの登録を行う" do
        expect(categories[:global]).to receive(:define_simple_item).with(item_name).and_call_original
        builder.define_simple_item(:global, item_name) do
          configuration do
          end
        end
      end

      context "指定したカテゴリが存在しない場合" do
        it "RGen::Builderエラーを発生させる" do
          expect {
            builder.define_simple_item(:foo, item_name) {}
          }.to raise_error RGen::BuilderError, "unknown category: foo"
        end
      end
    end

    describe "#define_list_item" do
      before do
        builder.input_component_store(:configuration) do
          entry do
            component_class   RGen::InputBase::Component
            component_factory RGen::InputBase::ComponentFactory
            item_base         RGen::InputBase::Item
            item_factory      RGen::InputBase::ItemFactory
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

      context "指定したカテゴリが存在しない場合" do
        it "RGen::Builderエラーを発生させる" do
          expect {
            builder.define_list_item(:foo, list_name) {}
          }.to raise_error RGen::BuilderError, "unknown category: foo"
          expect {
            builder.define_list_item(:foo, list_name, item_name) {}
          }.to raise_error RGen::BuilderError, "unknown category: foo"
        end
      end
    end


    describe "#enable" do
      before do
        builder.input_component_store(:configuration) do
          entry do
            component_class   RGen::InputBase::Component
            component_factory RGen::InputBase::ComponentFactory
            item_base         RGen::InputBase::Item
            item_factory      RGen::InputBase::ItemFactory
          end
        end

        [:baz, :qux].each do |item_name|
          builder.define_simple_item(:global, item_name) do
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

      context "指定したカテゴリが存在しない場合" do
        it "RGen::Builderエラーを発生させる" do
          expect {
            builder.enable(:foo, [:foo, :bar])
          }.to raise_error RGen::BuilderError, "unknown category: foo"
          expect {
            builder.enable(:foo, :qux)
          }.to raise_error RGen::BuilderError, "unknown category: foo"
          expect {
            builder.enable(:foo, :qux, :foo)
          }.to raise_error RGen::BuilderError, "unknown category: foo"
          expect {
            builder.enable(:foo, :qux, [:bar, :baz])
          }.to raise_error RGen::BuilderError, "unknown category: foo"
        end
      end
    end
  end
end
