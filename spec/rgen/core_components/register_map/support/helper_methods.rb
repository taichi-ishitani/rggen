def match_bit_field(parent, item_values)
  item_values[:register]  = parent
  be_kind_of(get_component_class(:register_map, 3)).and have_attributes(item_values)
end

def match_register(parent, item_values)
  item_values[:register_block]  = parent
  be_kind_of(get_component_class(:register_map, 2)).and have_attributes(item_values)
end

def match_register_block(parent, item_values)
  item_values[:register_map]  = parent
  be_kind_of(get_component_class(:register_map, 1)).and have_attributes(item_values)
end
