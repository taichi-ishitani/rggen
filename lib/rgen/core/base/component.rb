module RGen
  module Base
    class Component
      include HierarchicalStructure

      def initialize(parent = nil)
        super(parent)
        @items  = []
      end

      attr_reader :items

      def add_item(item)
        items << item
      end
    end
  end
end
