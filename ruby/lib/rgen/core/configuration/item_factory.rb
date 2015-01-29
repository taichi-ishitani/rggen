class RGen::Configuration::ItemFactory < RGen::InputBase::ItemFactory
  def create(configuration, data)
    item  = create_item(configuration, data)
    item.parse(data) unless data.nil?
    item
  end
end
