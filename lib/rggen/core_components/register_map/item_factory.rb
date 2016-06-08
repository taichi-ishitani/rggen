module RgGen
  module RegisterMap
    class ItemFactory < InputBase::ItemFactory
      include RaiseError

      def create(component, cell = nil)
        convert_cell_value(cell)
        create_item(component, cell) do |item|
          item.build(cell) unless cell.nil?
        end
      end

      private

      def convert_cell_value(cell)
        return if cell.nil?
        return if cell.empty?
        cell.value  = convert(cell.value)
      end

      def convert(cell)
        cell
      end
    end
  end
end
