module RgGen
  module RegisterMap
    class RegisterFactory < ComponentFactory
      def create_active_items(register, configuration, rows)
        active_item_factories.each_value.with_index do |factory, index|
          create_item(factory, register, configuration, rows.first[index])
        end
      end

      def create_children(register, configuration, rows)
        drop_size = active_item_factories.size
        rows.each do |row|
          create_child(register, configuration, row.drop(drop_size))
        end
      end
    end
  end
end
