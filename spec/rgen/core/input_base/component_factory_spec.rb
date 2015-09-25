require_relative  '../../../spec_helper'

module RGen::InputBase
  describe ComponentFactory do
    describe "#create" do
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
            component = Component.new
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
          Component.new
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
