module RGen
  module OutputBase
    class ItemFactory < Base::ItemFactory
      def create(component, configuration, source)
        item                = create_item(component, configuration, source)
        item.configuration  = configuration
        item.source         = source
        item
      end
    end
  end
end
