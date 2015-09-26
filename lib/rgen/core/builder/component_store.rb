module RGen::Builder
  class ComponentStore
    def initialize(builder, component_name)
      @builder        = builder
      @component_name = component_name
      @entries        = []
      @loaders        = []
    end

    attr_setter :loader_base

    def entry(associated_category = nil, &body)
      new_entry = ComponentEntry.new
      new_entry.instance_exec(&body)

      @builder.categories.each do |name, category|
        if associated_category.nil? || name == associated_category
          category.add_item_store(@component_name, new_entry.item_store)
        end
      end if new_entry.item_store

      @entries  << new_entry
    end

    def define_loader(type_or_types, &body)
      return unless loader_base
      l                 = Class.new(loader_base, &body)
      l.supported_types = Array(type_or_types)
      @loaders  << l
    end

    def build_factory
      factories = @entries.map(&:build_factory)
      factories.each_cons(2) do |factory_pair|
        factory_pair[0].child_factory = factory_pair[1]
      end

      factories.first.loaders = @loaders
      factories.first.root_factory

      factories.first
    end
  end
end
