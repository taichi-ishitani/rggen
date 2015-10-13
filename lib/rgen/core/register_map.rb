module RGen
  module RegisterMap
    require_relative 'register_map/generic_map'
    require_relative 'register_map/bit_field'
    require_relative 'register_map/register'
    require_relative 'register_map/register_block'
    require_relative 'register_map/register_map'
    require_relative 'register_map/loader'
    require_relative 'register_map/factory'
    require_relative 'register_map/item'
    require_relative 'register_map/item_factory'

    RGen.component_store(:register_map) do
      entry do
        component_class   RegisterMap
        component_factory Factory
      end

      entry(:register_block) do
        component_class   RegisterBlock::RegisterBlock
        component_factory RegisterBlock::Factory
        item_base(Item) do
          include Structure::RegisterBlock::Item
        end
        item_factory      ItemFactory
      end

      entry(:register) do
        component_class   Register::Register
        component_factory Register::Factory
        item_base(Item) do
          include Structure::Register::Item
        end
        item_factory      ItemFactory
      end

      entry(:bit_field) do
        component_class   BitField::BitField
        component_factory BitField::Factory
        item_base(Item) do
          include Structure::BitField::Item
        end
        item_factory      ItemFactory
      end

      loader_base Loader
    end
  end
end
