module RGen
  module Ral
    output_component_store :ral do
      entry do
        component_class   OutputBase::Component
        component_factory OutputBase::ComponentFactory
      end

      entry :register_block do
        component_class   OutputBase::Component
        component_factory OutputBase::ComponentFactory
        item_base         OutputBase::Item, include: Verilog
        item_factory      OutputBase::ItemFactory
      end

      entry :register do
        component_class   OutputBase::Component
        component_factory OutputBase::ComponentFactory
        item_base         OutputBase::Item, include: Verilog
        item_factory      OutputBase::ItemFactory
      end

      entry :bit_field do
        component_class   OutputBase::Component
        component_factory OutputBase::ComponentFactory
        item_base         OutputBase::Item, include: Verilog
        item_factory      OutputBase::ItemFactory
      end

      output_directory  'ral'
    end
  end
end
