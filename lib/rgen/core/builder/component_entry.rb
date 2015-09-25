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
      f                   = component_factory.new
      f.target_component  = component_class
      f.item_factories    = item_registry.build_factories if item_registry
      f
    end
  end
end
