module RGen
  module RegisterMap
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
