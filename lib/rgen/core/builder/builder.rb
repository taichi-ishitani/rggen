module RGen
  module Builder
    class Builder
      INITIAL_CATEGORIES  = [
        :global,
        :register_block,
        :register,
        :bit_field
      ].freeze

      def initialize
        @stores = Hash.new do |_, component_name|
          fail RGen::BuilderError, "unknown component: #{component_name}"
        end
        @categories = Hash.new do |_, category_name|
          fail RGen::BuilderError, "unknown category: #{category_name}"
        end
        INITIAL_CATEGORIES.each do |category_name|
          @categories[category_name]  = Category.new
        end
      end

      attr_reader :categories

      def input_component_store(component_name, &body)
        component_store(InputComponentStore, component_name, body)
      end

      def generator_component_store(component_name, &body)
        component_store(GeneratorComponentStore, component_name, body)
      end

      def define_loader(component_name, type_or_types, &body)
        @stores[component_name].define_loader(type_or_types, &body)
      end

      def build_factory(component_name)
        @stores[component_name].build_factory
      end

      def define_simple_item(category_name, item_name, &body)
        @categories[category_name].define_simple_item(item_name, &body)
      end

      def define_list_item(category_name, list_name, item_name = nil, &body)
        @categories[category_name].define_list_item(list_name, item_name, &body)
      end

      def enable(category_name, *list_name, item_or_itmes)
        @categories[category_name].enable(*list_name, item_or_itmes)
      end

      private

      def component_store(klass, component_name, body)
        unless @stores.key?(component_name)
          @stores[component_name] = klass.new(self, component_name)
        end
        @stores[component_name].instance_exec(&body)
      end
    end
  end
end
