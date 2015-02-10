def match_bit_field(parent, item_values)
  item_values[:register]  = parent
  be_kind_of(RGen::RegisterMap::BitField::BitField).and have_attributes(item_values)
end
