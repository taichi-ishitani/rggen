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

    RGen.input_component_store(:register_map) do
      entry do
        component_class   Component
        component_factory RegisterMapFactory
      end

      entry(:register_block) do
        component_class   Component
        component_factory RegisterBlockFactory
        item_base         Item
        item_factory      ItemFactory
      end

      entry(:register) do
        component_class   Component
        component_factory RegisterFactory
        item_base         Item
        item_factory      ItemFactory
      end

      entry(:bit_field) do
        component_class   Component
        component_factory BitFieldFactory
        item_base         Item
        item_factory      ItemFactory
      end

      loader_base Loader
    end
  end
end
