module RGen::RegisterMap::RegisterBlock
  class Factory < RGen::InputBase::ComponentFactory
    def create_items(register_block, configuration, sheet)
      @item_factories.each_value.with_index do |factory, index|
        create_item(factory, register_block, configuration, sheet[index, 2])
      end
    end

    def create_children(register_block, configuration, sheet)
      start_row     = @item_factories.size + 2
      start_column  = 1
      cell_blocks   = sheet.rows.from(start_row).each_with_object([]) do |row, blocks|
        next if row.all?(&:empty?)
        blocks      << [] unless row[start_column].empty?
        blocks.last << row.from(start_column)
      end

      cell_blocks.each do |block|
        create_child(register_block, configuration, block)
      end
    end
  end
end
