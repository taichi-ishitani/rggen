module RGen
  module OutputBase
    class ItemFactory < Base::ItemFactory
      def create(component, configuration, register_map)
        item  = create_item(component, configuration, register_map)
        item
      end
    end
  end
end
