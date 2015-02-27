module RGen::Builder
  class Builder
    INITIAL_CATEGORIES  = [
      :global,
      :register_block,
      :register,
      :bit_field
    ].freeze

    def initialize
      @registries = {}
      @categories = INITIAL_CATEGORIES.each_with_object({}) do |category, hash|
        hash[category]  = Category.new
      end
    end

    attr_reader :categories

    def component_registry(registry_name, &body)
      @registries[registry_name]  ||= ComponentRegistry.new(self, registry_name)
      @registries[registry_name].instance_exec(&body)
    end

    def register_loader(registry_name, *support_types, &body)
      @registries[registry_name].register_loader(*support_types, &body)
    end

    def build_factory(registry_name)
      @registries[registry_name].build_factory
    end

    def register_item(category_name, item_name, &body)
      @categories[category_name].register_item(item_name, &body)
    end

    def enable(category_name, item_or_itmes)
      @categories[category_name].enable(item_or_itmes)
    end
  end
end
