module RgGen
  module RegisterMap
    class ItemFactory < InputBase::ItemFactory
      include RaiseError

      def create(component, configuration, cell = nil)
        item  = create_item(component, cell)
        item.build(configuration, cell) unless cell.nil?
        item
      end
    end
  end
end
