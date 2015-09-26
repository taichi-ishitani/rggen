module RGen
  module Configuration
    require_relative 'configuration/configuration'
    require_relative 'configuration/item'
    require_relative 'configuration/factory'
    require_relative 'configuration/item_factory'

    RGen.component_store(:configuration) do
      entry do
        component_class   Configuration
        component_factory Factory
        item_base         Item
        item_factory      ItemFactory
      end

      loader_base InputBase::Loader
    end
  end
end
