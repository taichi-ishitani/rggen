module RGen
  module OutputBase
    class ComponentFactory < Base::ComponentFactory
      def create(*args)
        component = super(*args)
        component.build if @root_factory
        component
      end

      def create_component(parent, configuration, register_map)
        @target_component.new(parent, configuration, register_map)
      end

      def create_items(generator, configuration, soruce)
        @item_factories.each_value do |item_factory|
          create_item(item_factory, generator, configuration, soruce)
        end
      end

      def create_children(generator, configuration, source)
        source.children.each do |child_source|
          create_child(generator, configuration, child_source)
        end
      end
    end
  end
end
