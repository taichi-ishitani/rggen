module RGen
  module RegisterMap
    class BitFieldFactory < InputBase::ComponentFactory
      def create_active_items(bit_field, configuration, cells)
        active_item_factories.each_value.with_index do |factory, index|
          create_item(factory, bit_field, configuration, cells[index])
        end
      end
    end
  end
end
