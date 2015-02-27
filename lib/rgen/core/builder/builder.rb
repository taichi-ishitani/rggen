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

    def build_factory(registry_name)
      @registries[registry_name].build_factory
    end
  end
end
