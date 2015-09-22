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

    def component_registry(component_name, &body)
      @registries[component_name] ||= ComponentRegistry.new(self, component_name)
      @registries[component_name].instance_exec(&body)
    end

    def register_loader(component_name, type_or_types, &body)
      @registries[component_name].register_loader(type_or_types, &body)
    end

    def build_factory(component_name)
      @registries[component_name].build_factory
    end

    def register_value_item(category_name, item_name, &body)
      @categories[category_name].register_value_item(item_name, &body)
    end

    def register_list_item(category_name, list_name, item_name = nil, &body)
      @categories[category_name].register_list_item(list_name, item_name, &body)
    end

    def enable(category_name, *list_name, item_or_itmes)
      @categories[category_name].enable(*list_name, item_or_itmes)
    end
  end
end
