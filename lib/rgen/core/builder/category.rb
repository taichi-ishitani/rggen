module RGen::Builder
  class Category
    def initialize
      @item_registries  = {}
    end

    def append_item_registry(component_name, item_registry)
      return if @item_registries.key?(component_name)
      @item_registries[component_name]  = item_registry
      define_registry_method(component_name, item_registry)
    end

    def register_value_item(item_name, &body)
      do_registration(:register_value_item, item_name, &body)
    end

    def register_list_item(list_name, item_name = nil, &body)
      do_registration(:register_list_item, list_name, item_name, &body)
    end

    def enable(*list_name, item_or_items)
      @item_registries.each_value do |item_registry|
        item_registry.enable(*list_name, item_or_items)
      end
    end

    private

    def define_registry_method(component_name, item_registry)
      define_singleton_method(component_name) do |&body|
        item_registry.__send__(@register_method, *@arguments, &body)
      end
    end

    def do_registration(register_method, *arguments, &body)
      @register_method  = register_method
      @arguments        = arguments
      instance_exec(&body)
      remove_instance_variable(:@register_method)
      remove_instance_variable(:@arguments)
    end
  end
end
