class RGen::RegisterMap::BitField::Factory < RGen::InputBase::ComponentFactory
  def create_items(bit_field, configuration, cells)
    @item_factories.each_value.with_index do |factory, index|
      create_item(factory, bit_field, configuration, cells[index])
    end
  end
end
