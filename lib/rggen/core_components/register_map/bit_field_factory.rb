module RgGen
  module RegisterMap
    class BitFieldFactory < ComponentFactory
      def create_active_items(bit_field, cells)
        active_item_factories.each_value.with_index do |factory, index|
          create_item(factory, bit_field, cells[index])
        end
      end
    end
  end
end
