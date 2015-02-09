class RGen::RegisterMap::BitField::Item < RGen::RegisterMap::Base::Item
  def register_map
    bit_field.register_map
  end

  def register_block
    bit_field.register_block
  end

  def register
    bit_field.register
  end

  def bit_field
    owner
  end
end
