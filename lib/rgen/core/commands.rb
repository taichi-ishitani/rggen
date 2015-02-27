module RGen
  module Commands
    def generator
      @generator  ||= RGen::Generator.new
    end

    def component_registry(registry_name, &body)
      generator.builder.component_registry(registry_name, &body)
    end

    def item(category_name, item_name, &body)
      generator.builder.register_item(category_name, item_name, &body)
    end

    def loader(registry_name, type_or_types, &body)
      generator.builder.register_loader(registry_name, type_or_types, &body)
    end
  end

  extend Commands
end
