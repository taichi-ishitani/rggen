module RGen::InputBase
  class Component < RGen::Base::Component
    include SingleForwardable

    def append_item(item)
      super(item)
      def_object_delegators(item, *item.fields)
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
