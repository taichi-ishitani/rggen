module RGen
  module GeneratorBase
    class ItemFactory < Base::ItemFactory
      def create(generator, configuration, source)
        item                = create_item(generator, configuration, source)
        item.configuration  = configuration
        item.source         = source
        item
      end
    end
  end
end
