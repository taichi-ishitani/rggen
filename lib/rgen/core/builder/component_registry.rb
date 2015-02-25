module RGen::Builder
  class ComponentRegistry
    def initialize(builder, name)
      @builder  = builder
      @name     = name
      @entries  = []
    end

    def register_component(assosiated_category = nil, &body)
      entry = ComponentEntry.new
      entry.instance_exec(&body)

      @builder.categories.each do |name, category|
        if assosiated_category.nil? || name == assosiated_category
          category.append_item_registry(@name, entry.item_registry)
        end
      end if entry.item_registry

      @entries  << entry
    end
  end
end
