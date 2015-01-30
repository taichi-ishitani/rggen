class RGen::Configuration::Factory < RGen::InputBase::ComponentFactory
  def create_items(configuration, hash)
    @item_factories.each do |name, factory|
      create_item(factory, configuration, hash[name])
    end
  end

  def load(file)
    unless file.nil? || file.empty?
      load_data = load_file(file)
      unless load_data.kind_of?(Hash)
        raise RGen::LoadError, "Hash type required for configuration: #{load_data.class}}"
      end
    else
      load_data = {}
    end
    load_data
  end
end
