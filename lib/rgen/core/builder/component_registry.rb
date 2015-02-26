module RGen::Builder
  class ComponentRegistry
    def initialize(builder, name)
      @builder  = builder
      @name     = name
      @entries  = []
      @loaders  = []
    end

    attr_setter :loader_base

    def register_component(associated_category = nil, &body)
      entry = ComponentEntry.new
      entry.instance_exec(&body)

      @builder.categories.each do |name, category|
        if associated_category.nil? || name == associated_category
          category.append_item_registry(@name, entry.item_registry)
        end
      end if entry.item_registry

      @entries  << entry
    end

    def register_loader(*support_types, &body)
      return unless loader_base
      loader  = Class.new(loader_base, &body)
      loader.support_types(*support_types)
      @loaders  << loader
    end

    def build_factory
      @entries.each_with_object([]) do |entry, factories|
        if factories.empty?
          factory = build_root_factory(entry)
        else
          factory = entry.build_factory
          factories.last.register_child_factory(factory)
        end
        factories << factory
      end.first
    end

    private

    def build_root_factory(entry)
      factory = entry.build_factory
      factory.root_factory
      @loaders.each do |loader|
        factory.register_loader(loader)
      end
      factory
    end
  end
end
