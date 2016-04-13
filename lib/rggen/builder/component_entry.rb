module RgGen
  module Builder
    class ComponentEntry
      class << self
        private

        def rggen_class_setter(class_type)
          variable_name = class_type.variablize
          define_method(class_type) do |base_class = nil, options = {}, &body|
            if base_class && !instance_variable_defined?(variable_name)
              klass = define_rggen_class(base_class, options, body)
              instance_variable_set(variable_name, klass)
            end
            instance_variable_get(variable_name)
          end
        end
      end

      rggen_class_setter :component_class
      rggen_class_setter :component_factory
      rggen_class_setter :item_base
      rggen_class_setter :item_factory

      def item_store
        return nil unless item_base && item_factory
        @item_store ||= ItemStore.new(item_base, item_factory)
      end

      def build_factory
        component_factory.new.tap do |f|
          f.target_component  = component_class
          f.item_factories    = item_store.build_factories if item_store
        end
      end

      private

      def define_rggen_class(base_class, options, body)
        if options.key?(:include) || body
          Class.new(base_class) do
            include(*Array(options[:include])) if options.key?(:include)
            class_exec(&body) if body
          end
        else
          base_class
        end
      end
    end
  end
end
