module RGen
  module Base
    module HierarchicalStructure
      def initialize(parent = nil)
        @parent   = parent
        @children = []
        @level    = (parent && parent.level + 1) || 0
      end

      attr_reader :parent
      attr_reader :children
      attr_reader :level

      def add_child(child)
        @children << child
      end
    end
  end
end
