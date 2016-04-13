module RgGen
  module Base
    class Component
      include SingleForwardable

      def initialize(parent)
        @parent   = parent
        @children = []
        @level    = (parent && parent.level + 1) || 0
        @items    = []
      end

      attr_reader :parent
      attr_reader :children
      attr_reader :level
      attr_reader :items

      def add_child(child)
        @children << child
      end

      def add_item(item)
        items << item
      end
    end
  end
end
