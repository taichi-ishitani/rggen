module RGen::Builder
  class Category
    def initialize
      @registries = {}
    end

    attr_reader :registries

    def create_registry(name, &body)
      unless registries[name]
        registries[name]  = RGen::Builder::Registry.new
        define_registry_method(name)
      end
      registries[name].instance_exec(&body)
    end

    def register_entry(name, &body)
      @current_entry_name = name
      instance_exec(&body)
    end

    def enable(*enabled_items)
      registries.each_value do |registry|
        registry.enable(*enabled_items)
      end
    end

    def enabled_factories(registry_name)
      registries[registry_name].enabled_factories
    end

    private

    def define_registry_method(name)
      define_singleton_method(name) do |&body|
        registries[name].register_item(@current_entry_name, &body)
      end
    end
  end
end
