def match_address_width(width)
  have_attributes(address_width: width)
end

def clear_enabled_items
  RGen.generator.builder.categories.each_value do |category|
    category.instance_variable_get(:@item_registries).each_value do |item_registry|
      item_registry.instance_variable_get(:@enabled_items).clear
    end
  end
end
