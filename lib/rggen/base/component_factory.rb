module RgGen
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
          create_items(component, *sources) if create_items?
          parent.add_child(component) if child_factory?
          create_children(component, *sources) if create_children?(component)
        end
      end

      def root_factory
        @root_factory = true
      end

      private

      def child_factory?
        !@root_factory
      end

      def create_items?
        @item_factories.not_nil?
      end

      def create_children?(component)
        @child_factory.not_nil? && component.need_children?
      end

      def create_component(parent, *_sources)
        @target_component.new(parent)
      end

      def create_item(item_factory, component, *sources)
        item_factory.create(component, *sources)
      end

      def create_child(component, *sources)
        @child_factory.create(component, *sources)
      end
    end
  end
end
