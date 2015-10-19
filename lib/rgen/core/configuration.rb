module RGen
  module Configuration
    require_relative 'configuration/raise_error'
    require_relative 'configuration/item'
    require_relative 'configuration/configuration_factory'
    require_relative 'configuration/item_factory'

    RGen.input_component_store(:configuration) do
      entry do
        component_class   InputBase::Component
        component_factory ConfigurationFactory
        item_base         Item
        item_factory      ItemFactory
      end

      loader_base InputBase::Loader
    end
  end
end
