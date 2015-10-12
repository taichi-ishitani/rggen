module RGen::Builder
  class ComponentEntry
    class << self
      private

      def rgen_class_setter(class_type)
        variable_name = class_type.variablize
        define_method(class_type) do |base_class = nil, &body|
          unless base_class.nil? || instance_variable_defined?(variable_name)
            klass = (body && Class.new(base_class, &body)) || base_class
            instance_variable_set(variable_name, klass)
          end
          instance_variable_get(variable_name)
        end
      end
    end

    rgen_class_setter :component_class
    rgen_class_setter :component_factory
    rgen_class_setter :item_base
    rgen_class_setter :item_factory

    def item_store
      return nil unless item_base && item_factory
      @item_Store ||= ItemStore.new(item_base, item_factory)
    end

    def build_factory
      f                   = component_factory.new
      f.target_component  = component_class
      f.item_factories    = item_store.build_factories if item_store
      f
    end
  end
end
