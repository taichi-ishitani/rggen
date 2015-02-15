module RGen::RegisterMap::Register
  class Factory < RGen::InputBase::ComponentFactory
    def create_items(register, configuration, rows)
      @item_factories.each_value.with_index do |factory, index|
        create_item(factory, register, configuration, rows.first[index])
      end
    end

    def create_children(register, configuration, rows)
      rows.each do |row|
        create_child(register, configuration, row.drop(@item_factories.size))
      end
    end
  end
end
