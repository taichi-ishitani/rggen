module RGen::RegisterMap::RegisterBlock
  class Factory < RGen::InputBase::ComponentFactory
    private

    def create_items(register_block, configuration, sheet)
      @item_factories.each_value.with_index do |factory, index|
        create_item(factory, register_block, configuration, sheet[index, 2])
      end
    end

    def create_children(register_block, configuration, sheet)
      cell_blocks(sheet).each do |block|
        create_child(register_block, configuration, block)
      end
    end

    def cell_blocks(sheet)
      start_row     = @item_factories.size + 2
      start_column  = 1

      sheet.rows.from(start_row).each_with_object([]) do |row, blocks|
        valid_cells = row.from(start_column)
        next if valid_cells.all?(&:empty?)
        blocks      << [] unless valid_cells.first.empty?
        blocks.last << valid_cells
      end
    end
  end
end
