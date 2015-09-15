module RGen::Builder
  class Category
    def initialize
      @item_registries  = {}
    end

    def append_item_registry(component_name, item_registry)
      return if @item_registries.key?(component_name)
      @item_registries[component_name]  = item_registry
      define_registry_method(component_name)
    end

    def register_value_item(item_name, &body)
      do_registration(:register_value_item, item_name, &body)
    end

    def enable(item_or_items)
      @item_registries.each_value do |item_registry|
        item_registry.enable(item_or_items)
      end
    end

    private

    def define_registry_method(component_name)
      define_singleton_method(component_name) do |&body|
        @item_registries[component_name].__send__(@current_register_method, *@current_arguments, &body)
      end
    end

    def do_registration(register_method, *arguments, &body)
      @current_register_method  = register_method
      @current_arguments        = arguments
      instance_exec(&body)
      remove_instance_variable(:@current_register_method)
      remove_instance_variable(:@current_arguments)
    end
  end
end
