module RgGen
  module Configuration
    input_component_store :configuration do
      entry do
        component_class   InputBase::Component
        component_factory ConfigurationFactory
        item_base         InputBase::Item, include: RaiseError
        item_factory      ItemFactory
      end

      loader_base InputBase::Loader
    end
  end
end
