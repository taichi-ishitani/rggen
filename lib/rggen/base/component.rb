module RgGen
  module Base
    class Component
      include SingleForwardable

      def initialize(parent)
        @parent         = parent
        @children       = []
        @level          = (parent && parent.level + 1) || 0
        @items          = []
        @need_children  = true
      end

      attr_reader :parent
      attr_reader :children
      attr_reader :level
      attr_reader :items

      def need_no_children
        @need_children  = false
      end

      def need_children?
        @need_children
      end

      def add_child(child)
        @children << child if need_children?
      end

      def add_item(item)
        items << item
      end
    end
  end
end
