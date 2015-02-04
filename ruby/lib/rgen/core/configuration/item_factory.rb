class RGen::Configuration::ItemFactory < RGen::InputBase::ItemFactory
  def create(configuration, data)
    item  = create_item(configuration, data)
    item.build(data) unless data.nil?
    item
  end
end
