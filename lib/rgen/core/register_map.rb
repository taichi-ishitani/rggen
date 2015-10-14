module RGen
  module RegisterMap
    require_relative 'register_map/generic_map'
    require_relative 'register_map/loader'
    require_relative 'register_map/component'
    require_relative 'register_map/item'
    require_relative 'register_map/register_map_factory'
    require_relative 'register_map/register_block_factory'
    require_relative 'register_map/register_factory'
    require_relative 'register_map/bit_field_factory'

    require_relative 'register_map/item_factory'

    RGen.component_store(:register_map) do
      entry do
        component_class(Component)
        component_factory(InputBase::ComponentFactory) do
          include RegisterMapFactory
        end
      end

      entry(:register_block) do
        component_class(Component)
        component_factory(InputBase::ComponentFactory) do
          include RegisterBlockFactory
        end
        item_base(Item) do
          include Structure::RegisterBlock::Item
        end
        item_factory(ItemFactory)
      end

      entry(:register) do
        component_class(Component)
        component_factory(InputBase::ComponentFactory) do
          include RegisterFactory
        end
        item_base(Item) do
          include Structure::Register::Item
        end
        item_factory(ItemFactory)
      end

      entry(:bit_field) do
        component_class(Component)
        component_factory(InputBase::ComponentFactory) do
          include BitFieldFactory
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

