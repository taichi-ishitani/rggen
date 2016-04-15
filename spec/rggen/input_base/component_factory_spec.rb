require_relative  '../../spec_helper'

module RgGen::InputBase
  describe ComponentFactory do
    describe "#create" do
      describe "アイテムオブジェクトの生成" do
        let(:parent) do
          Component.new(nil)
        end

        let(:component) do
          Component.new(parent)
        end

        let(:active_item) do
          Class.new(Item) do
            build {}
          end
        end

        let(:passive_item) do
          Class.new(Item)
        end

        let(:active_item_factory) do
          f = ItemFactory.new
          f.target_item = active_item
          f
        end

        let(:passive_item_factory) do
          f = ItemFactory.new
          f.target_item = passive_item
          f
        end

        let(:factory) do
          c = component
          f = Class.new(ComponentFactory) {
            define_method(:create_component) {|*args| c}
            def create_active_items(component, *args)
              active_item_factories.each_value.with_index do |f, i|
                create_item(f, component, *args[0..-2], args[-1][i])
              end
            end
          }.new
          f.target_component  = Component
          f.item_factories    = {foo: active_item_factory, bar: passive_item_factory, baz:passive_item_factory, qux: active_item_factory}
          f
        end

        let(:other_argument) do
          Object.new
        end

        let(:common_arguments) do
          [component, other_argument]
        end

        describe "active_itemオブジェクトの生成" do
          specify "#buildの末尾の引数を各アイテム向けの引数、それ以外の引数を共通引数として、アイテムの生成を行う" do
            expect(active_item_factory).to receive(:create).with(*common_arguments, :foo).and_call_original
            expect(active_item_factory).to receive(:create).with(*common_arguments, :qux).and_call_original
            factory.create(parent, other_argument, [:foo, :qux])
          end
        end

        describe "#passive_itemオブジェクトの生成" do
          specify "#buildの末尾以外の引数を共通引数として、アイテムの生成を行う" do
            expect(passive_item_factory).to receive(:create).with(*common_arguments).and_call_original
            expect(passive_item_factory).to receive(:create).with(*common_arguments).and_call_original
            factory.create(parent, other_argument, [:foo, :qux])
          end
        end

        it "登録された順に関わらず、active_itemオブジェクトの生成後にpassive_itemオブジェクトの生成を行う" do
          expect(active_item_factory ).to receive(:create).ordered.and_call_original
          expect(active_item_factory ).to receive(:create).ordered.and_call_original
          expect(passive_item_factory).to receive(:create).ordered.and_call_original
          expect(passive_item_factory).to receive(:create).ordered.and_call_original
          factory.create(parent, other_argument, [:foo, :qux])
        end
      end

      context "ルートファクトリのとき" do
        let(:file_name) do
          "test.foo"
        end

        let(:foo_loader) do
          Class.new(Loader) do
            self.supported_types  = [:foo]
            def load_file(file)
            end
          end
        end

        let(:bar_loader) do
          Class.new(Loader) do
            self.supported_types  = [:bar]
          end
        end

        context "入力ファイルに対応するローダが登録されている場合" do
          let(:factory) do
            f = ComponentFactory.new
            f.target_component  = Component
            f.loaders           = [foo_loader]
            f.root_factory
            f
          end

          it "ローダの#load_fileを呼び出す" do
            loader  = double("loader")
            foo_loader.define_singleton_method(:new) do
              loader
            end

            expect(loader).to receive(:load_file).with(file_name)
            factory.create(file_name)
          end

          it "生成したコンポーネントオブジェクトの#validateを呼び出す" do
            component = Component.new(nil)
            factory.define_singleton_method(:create_component) do |*args|
              component
            end

            expect(component).to receive(:validate).with(no_args)
            factory.create(file_name)
          end
        end

        context "入力ファイルに対応するローダが登録されていない場合" do
          it "LoadErrorを発生させる" do
            f = ComponentFactory.new
            f.target_component  = Component
            f.loaders           = [bar_loader]
            f.root_factory

            expect {f.create(file_name)}.to raise_load_error "unsupported file type: foo"
          end
        end
      end

      context "ルートファクトリではないとき" do
        let(:parent) do
          Component.new(nil)
        end

        it "生成したコンポーネントオブジェクトの#validateを呼び出さない" do
          component = Component.new(parent)

          f = Class.new(ComponentFactory) {
            define_method(:create_component) do |*args|
              component
            end
          }.new

          expect(component).not_to receive(:validate)
          f.create(parent)
        end
      end
    end
  end
end
