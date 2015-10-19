module RGen
  module GeneratorBase
    class GeneratorFactory < Base::ComponentFactory
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
