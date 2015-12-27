module RGen
  module Base
    class ComponentFactory
      attr_writer :target_component
      attr_writer :item_factories
      attr_writer :child_factory

      def create(*args)
        parent  = (@root_factory) ? nil : args.shift
        sources = args

        component = create_component(parent, *sources)
        create_items(component, *sources) if @item_factories
        parent.add_child(component) unless @root_factory
        create_children(component, *sources) if @child_factory

        component
      end

      def root_factory
        @root_factory = true
      end

      private

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
