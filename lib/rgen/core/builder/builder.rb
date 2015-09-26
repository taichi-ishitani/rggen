module RGen::Builder
  class Builder
    INITIAL_CATEGORIES  = [
      :global,
      :register_block,
      :register,
      :bit_field
    ].freeze

    def initialize
      @stores     = {}
      @categories = INITIAL_CATEGORIES.each_with_object({}) do |category, hash|
        hash[category]  = Category.new
      end
    end

    attr_reader :categories

    def component_store(component_name, &body)
      @stores[component_name] ||= ComponentStore.new(self, component_name)
      @stores[component_name].instance_exec(&body)
    end

    def define_loader(component_name, type_or_types, &body)
      @stores[component_name].define_loader(type_or_types, &body)
    end

    def build_factory(component_name)
      @stores[component_name].build_factory
    end

    def define_value_item(category_name, item_name, &body)
      @categories[category_name].define_value_item(item_name, &body)
    end

    def define_list_item(category_name, list_name, item_name = nil, &body)
      @categories[category_name].define_list_item(list_name, item_name, &body)
    end

    def enable(category_name, *list_name, item_or_itmes)
      @categories[category_name].enable(*list_name, item_or_itmes)
    end
  end
end
