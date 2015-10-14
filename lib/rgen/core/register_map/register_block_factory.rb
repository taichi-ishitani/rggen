module RGen
  module RegisterMap
    module RegisterBlockFactory
      def create_active_items(register_block, configuration, sheet)
        active_item_factories.each_value.with_index do |factory, index|
          cell  = sheet[index, 2]
          create_item(factory, register_block, configuration, cell)
        end
      end

      def create_children(register_block, configuration, sheet)
        cell_blocks(sheet).each do |block|
          create_child(register_block, configuration, block)
        end
      end

      def cell_blocks(sheet)
        drop_row_size     = active_item_factories.size + 2
        drop_column_size  = 1
        sheet.rows.drop(drop_row_size).each_with_object([]) do |row, blocks|
          valid_cells = row.drop(drop_column_size)
          next if valid_cells.all?(&:empty?)
          blocks      << [] unless valid_cells.first.empty?
          blocks.last << valid_cells
        end
      end
    end
  end
end
