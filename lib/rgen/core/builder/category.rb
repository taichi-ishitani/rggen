module RGen::Builder
  class Category
    def initialize
      @item_registries  = {}
    end

    def append_item_registry(name, item_registry)
      unless @item_registries.key?(name)
        @item_registries[name]  = item_registry
        define_registry_method(name)
      end
    end

    def register_item(item_name, &body)
      @current_item_name  = item_name
      instance_exec(&body)
    end

    private

    def define_registry_method(name)
      define_singleton_method(name) do |&body|
        @item_registries[name].register_item(@current_item_name, &body)
      end
    end
  end
end
