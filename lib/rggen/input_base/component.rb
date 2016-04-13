module RgGen
  module InputBase
    class Component < Base::Component
      def add_item(item)
        super(item)
        def_object_delegators(@items.last, *item.fields)
      end

      def fields
        items.flat_map(&:fields)
      end

      def validate
        items.each(&:validate)
        children.each(&:validate)
      end
    end
  end
end
