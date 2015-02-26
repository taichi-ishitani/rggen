module RGen::Builder
  class ComponentRegistry
    def initialize(builder, name)
      @builder  = builder
      @name     = name
      @entries  = []
    end

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
  end
end
