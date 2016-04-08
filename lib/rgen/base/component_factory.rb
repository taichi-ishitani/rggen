module RGen
  module Base
    class ComponentFactory
      def initialize
        @root_factory = false
      end

      attr_writer :target_component
      attr_writer :item_factories
      attr_writer :child_factory

      def create(*args)
        parent  = (child_factory? && args.shift) || nil
        sources = args
        create_component(parent, *sources).tap do |component|
          create_items(component, *sources) if @item_factories
          parent.add_child(component) unless @root_factory
          create_children(component, *sources) if @child_factory
        end
      end

      def root_factory
        @root_factory = true
      end

      private

      def child_factory?
        !@root_factory
      end

      def create_component(parent, *_sources)
        @target_component.new(parent)
      end

      def create_item(item_factory, component, *sources)
        item  = item_factory.create(component, *sources)
        component.add_item(item)
      end

      def create_child(component, *sources)
        @child_factory.create(component, *sources)
      end
    end
  end
end
