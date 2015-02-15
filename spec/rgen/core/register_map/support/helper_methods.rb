def match_bit_field(parent, item_values)
  item_values[:register]  = parent
  be_kind_of(RGen::RegisterMap::BitField::BitField).and have_attributes(item_values)
end

def match_register(parent, item_values)
  item_values[:register_block]  = parent
  be_kind_of(RGen::RegisterMap::Register::Register).and have_attributes(item_values)
end

def match_register_block(parent, item_values)
  item_values[:register_map]  = parent
  be_kind_of(RGen::RegisterMap::RegisterBlock::RegisterBlock).and have_attributes(item_values)
end
