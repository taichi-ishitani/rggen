require_relative  '../../spec_helper'

module RgGen::Builder
  describe InputComponentStore do
    let(:builder) do
      Builder.new
    end

    let(:registry_name) do
      :foo
    end

    let(:component_store) do
      InputComponentStore.new(builder, registry_name)
    end

    let(:loader_base) do
      RgGen::InputBase::Loader
    end

    let(:loaders) do
      component_store.instance_variable_get(:@loaders)
    end

    describe "#define_loader" do
      before do
        component_store.entry do
          component_class   RgGen::InputBase::Component
          component_factory RgGen::InputBase::ComponentFactory
          item_base         RgGen::InputBase::Item
          item_factory      RgGen::InputBase::ItemFactory
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
        component_store.loader_base(loader_base)
        component_store.entry do
          component_class   RgGen::InputBase::Component
          component_factory RgGen::InputBase::ComponentFactory do
          end
        end
        component_store.entry(:register_block) do
          component_class   RgGen::InputBase::Component
          component_factory RgGen::InputBase::ComponentFactory do
          end
        end
        component_store.entry(:register) do
          component_class   RgGen::InputBase::Component
          component_factory RgGen::InputBase::ComponentFactory do
          end
        end
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
