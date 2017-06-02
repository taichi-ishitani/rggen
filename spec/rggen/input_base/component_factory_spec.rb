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
          ItemFactory.new.tap do |f|
            f.target_item = active_item
            def f.create(*args)
              create_item(*args)
            end
          end
        end

        let(:passive_item_factory) do
          ItemFactory.new.tap do |f|
            f.target_item = passive_item
            def f.create(*args)
              create_item(*args)
            end
          end
        end

        let(:factory) do
          f = Class.new(ComponentFactory) {
            def create_active_items(component, *args)
              active_item_factories.each_value.with_index do |f, i|
                create_item(f, component, *args[0..-2], args[-1][i])
              end
            end
          }.new
          f.target_component  = Component
          f.item_factories    = {foo: active_item_factory, bar: passive_item_factory, baz:passive_item_factory, qux: active_item_factory}
          allow(f).to receive(:create_component).and_return(component)
          f
        end

        let(:other_argument) do
          Object.new
        end

        describe "active_itemオブジェクトの生成" do
          specify "所有者コンポーネントと#buildの末尾の引数を用いてアイテムの生成を行う" do
            expect(active_item_factory).to receive(:create).with(component, :foo).and_call_original
            expect(active_item_factory).to receive(:create).with(component, :bar).and_call_original
            factory.create(parent, other_argument, [:foo, :bar])
          end
        end

        describe "#passive_itemオブジェクトの生成" do
          specify "#buildの末尾以外の引数を共通引数として、アイテムの生成を行う" do
            expect(passive_item_factory).to receive(:create).with(component).and_call_original
            expect(passive_item_factory).to receive(:create).with(component).and_call_original
            factory.create(parent, other_argument, [:foo, :bar])
          end
        end

        it "登録された順に関わらず、active_itemオブジェクトの生成後にpassive_itemオブジェクトの生成を行う" do
          expect(active_item_factory ).to receive(:create).ordered.and_call_original
          expect(active_item_factory ).to receive(:create).ordered.and_call_original
          expect(passive_item_factory).to receive(:create).ordered.and_call_original
          expect(passive_item_factory).to receive(:create).ordered.and_call_original
          factory.create(parent, other_argument, [:foo, :bar])
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

        let(:factory) do
          ComponentFactory.new.tap do |f|
            f.target_component  = Component
            f.loaders           = [foo_loader]
            f.root_factory
          end
        end

        context "入力ファイルがサポートするタイプの場合" do
          before do
            allow(factory).to receive(:create_component).and_return(component)
          end

          before do
            allow(File).to receive(:exist?).with(file_name).and_return(true)
          end

          let(:component) do
            Component.new(nil)
          end

          it "対応するローダを使って、ファイルを読み出す" do
            expect_any_instance_of(foo_loader).to receive(:load).with(file_name)
            factory.create(file_name)
          end

          it "生成したコンポーネントオブジェクトのバリデーションを行う" do
            expect(component).to receive(:validate).with(no_args)
            factory.create(file_name)
          end
        end

        context "入力ファイルに対応するローダが登録されていない場合" do
          it "LoadErrorを発生させる" do
            expect {
              factory.create("test.bar")
            }.to raise_load_error "unsupported file type -- test.bar"
          end
        end
      end

      context "ルートファクトリではないとき" do
        let(:parent) do
          Component.new(nil)
        end

        let(:component) do
          Component.new(parent)
        end

        let(:factory) do
          ComponentFactory.new.tap do |f|
            allow(f).to receive(:create_component).and_return(component)
          end
        end

        it "生成したコンポーネントオブジェクトの#validateを呼び出さない" do
          expect(component).not_to receive(:validate)
          factory.create(parent)
        end
      end
    end
  end
end
