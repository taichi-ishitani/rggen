module RGen
  module Rtl
    RGen.output_component_store(:rtl) do
      entry do
        component_class   OutpuBase::Component
        component_factory OutpuBase::ComponentFactory
      end

      entry(:register_block) do
        component_class   Component
        component_factory OutpuBase::ComponentFactory
        item_base         Item
        item_factory      OutpuBase::ItemFactory
      end

      entry(:register) do
        component_class   Component
        component_factory OutpuBase::ComponentFactory
        item_base         Item
        item_factory      OutpuBase::ItemFactory
      end

      entry(:bit_field) do
        component_class   Component
        component_factory OutpuBase::ComponentFactory
        item_base         Item
        item_factory      OutpuBase::ItemFactory
      end
    end
  end
end
