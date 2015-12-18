require_relative  '../../spec_helper'

module RGen::Builder
  describe OutputComponentStore do
    let(:builder) do
      Builder.new
    end

    let(:registry_name) do
      :foo
    end

    let(:component_store) do
      OutputComponentStore.new(builder, registry_name)
    end

    describe "#build_factory" do
      let(:output_directory) do
        'foo'
      end

      before do
        component_store.output_directory(output_directory)
        component_store.entry do
          component_class   RGen::OutputBase::Component
          component_factory RGen::OutputBase::ComponentFactory do
          end
        end
        component_store.entry(:register_block) do
          component_class   RGen::OutputBase::Component
          component_factory RGen::OutputBase::ComponentFactory do
          end
        end
        component_store.entry(:register) do
          component_class   RGen::OutputBase::Component
          component_factory RGen::OutputBase::ComponentFactory do
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

      specify "ルートファクトリのみ出力ディレクトリが設定される" do
        built_factories.each_with_index do |f, i|
          if i == 0
            expect(f.instance_variable_get(:@output_directory)).to eq output_directory
          else
            expect(f.instance_variable_get(:@output_directory)).to be_nil
          end
        end
      end
    end
  end
end
