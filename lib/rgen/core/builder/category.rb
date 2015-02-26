module RGen::Builder
  class Category
    def initialize
      @item_registries  = {}
    end

    def append_item_registry(name, item_registry)
      return if @item_registries.key?(name)
      @item_registries[name]  = item_registry
      define_registry_method(name)
    end

    def register_item(item_name, &body)
      @current_item_name  = item_name
      instance_exec(&body)
      @current_item_name  = nil
    end

    def enable(*item_names)
      @item_registries.each_value do |item_registry|
        item_registry.enable(*item_names)
      end
    end

    private

    def define_registry_method(name)
      define_singleton_method(name) do |&body|
        @item_registries[name].register_item(@current_item_name, &body)
      end
    end
  end
end
