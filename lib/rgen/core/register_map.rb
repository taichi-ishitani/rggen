module RGen
  module RegisterMap
    require_relative 'register_map/generic_map'
    require_relative 'register_map/base'
    require_relative 'register_map/bit_field'
    require_relative 'register_map/register'
    require_relative 'register_map/register_block'
    require_relative 'register_map/register_map'
    require_relative 'register_map/loader'
    require_relative 'register_map/factory'

    RGen.component_registry(:register_map) do
      register_component do
        component_class   RegisterMap
        component_factory Factory
      end

      register_component(:register_block) do
        component_class   RegisterBlock::RegisterBlock
        component_factory RegisterBlock::Factory
        item_base         RegisterBlock::Item
        item_factory      RegisterBlock::ItemFactory
      end

      register_component(:register) do
        component_class   Register::Register
        component_factory Register::Factory
        item_base         Register::Item
        item_factory      Register::ItemFactory
      end

      register_component(:bit_field) do
        component_class   BitField::BitField
        component_factory BitField::Factory
        item_base         BitField::Item
        item_factory      BitField::ItemFactory
      end

      loader_base Loader
    end
  end
end
