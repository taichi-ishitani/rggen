module RGen::Builder
  class ComponentEntry
    attr_setter :component_class
    attr_setter :component_factory
    attr_setter :item_base
    attr_setter :item_factory

    def item_registry
      return nil unless item_base && item_factory
      @item_registry  ||= ItemRegistry.new(item_base, item_factory)
    end

    def build_factory
      factory = component_factory.new
      factory.register_component(component_class)

      item_registry.enabled_factories.each do |name, item_factory|
        factory.register_item_factory(name, item_factory)
      end if item_registry

      factory
    end
  end
end
