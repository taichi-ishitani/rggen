class RGen::Configuration::Factory < RGen::InputBase::ComponentFactory
  def create_items(configuration, hash)
    @item_factories.each do |name, factory|
      create_item(factory, configuration, hash[name])
    end
  end

  def load(file)
    return {} if file.nil? || file.empty?

    load_data = load_file(file)
    if load_data.kind_of?(Hash)
      load_data.symbolize_keys!
    else
      fail RGen::LoadError, "Hash type required for configuration: #{load_data.class}}"
    end
  end
end
