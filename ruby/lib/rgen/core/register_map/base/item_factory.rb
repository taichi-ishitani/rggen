class RGen::RegisterMap::Base::ItemFactory < RGen::InputBase::ItemFactory
  def create(component, configuration, cell)
    item  = create_item(component, configuration, cell)
    item.build(configuration, cell)
    item
  end
end
