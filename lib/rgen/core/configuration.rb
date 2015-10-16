module RGen
  module Configuration
    require_relative 'configuration/raise_error'
    require_relative 'configuration/configuration_factory'
    require_relative 'configuration/item_factory'

    RGen.input_component_store(:configuration) do
      entry do
        component_class(InputBase::Component)
        component_factory(InputBase::ComponentFactory) do
          include ConfigurationFactory
        end
        item_base(InputBase::Item) do
          include RaiseError
        end
        item_factory(InputBase::ItemFactory) do
          include RaiseError
          include ItemFactory
        end
      end

      loader_base InputBase::Loader
    end
  end
end
