module RGen
  module RegisterMap
    require_relative 'register_map/generic_map'
    require_relative 'register_map/loader'
    require_relative 'register_map/factory'
    require_relative 'register_map/item'
    require_relative 'register_map/item_factory'

    RGen.component_store(:register_map) do
      entry do
        component_class(InputBase::Component) do
          include Structure::RegisterMap::Component
        end
        component_factory Factory
      end

      entry(:register_block) do
        component_class(InputBase::Component) do
          include Structure::RegisterBlock::Component
        end

        component_factory(InputBase::ComponentFactory) do
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

            valid_rows  =sheet.rows.drop(drop_row_size)
            valid_rows.each_with_object([]) do |row, blocks|
              valid_cells = row.drop(drop_column_size)
              next if valid_cells.all?(&:empty?)
              blocks      << [] unless valid_cells.first.empty?
              blocks.last << valid_cells
            end
          end
        end

        item_base(Item) do
          include Structure::RegisterBlock::Item
        end

        item_factory(ItemFactory)
      end

      entry(:register) do
        component_class(InputBase::Component) do
          include Structure::Register::Component
        end

        component_factory(InputBase::ComponentFactory) do
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

        item_base(Item) do
          include Structure::Register::Item
        end

        item_factory(ItemFactory)
      end

      entry(:bit_field) do
        component_class(InputBase::Component) do
          include Structure::BitField::Component
        end

        component_factory(InputBase::ComponentFactory) do
          def create_active_items(bit_field, configuration, cells)
            active_item_factories.each_value.with_index do |factory, index|
              create_item(factory, bit_field, configuration, cells[index])
            end
          end
        end

        item_base(Item) do
          include Structure::BitField::Item
        end

        item_factory(ItemFactory)
      end

      loader_base Loader
    end
  end
end
