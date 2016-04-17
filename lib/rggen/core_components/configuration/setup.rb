module RgGen
  module Configuration
    input_component_store :configuration do
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
