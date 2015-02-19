module RGen::Builder
  class ComponentEntry
    def initialize(component_class, component_factory, item_class = nil, item_factory = nil)
      @component_class    = component_class
      @component_factory  = component_factory
      @item_registry      = ItemRegistry.new(item_class, item_factory) if item_class
    end

    attr_reader :item_registry

    def build_factory
      factory = @component_factory.new
      factory.register_component(@component_class)

      item_registry.enabled_factories.each do |name, item_factory|
        factory.register_item_factory(name, item_factory)
      end if item_registry

      factory
    end
  end
end
