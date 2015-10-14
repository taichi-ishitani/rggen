module RGen
  module Base
    module HierarchicalStructure
      def initialize(parent = nil)
        @parent   = parent
        @children = []
      end

      attr_reader :parent
      attr_reader :children

      def add_child(child)
        @children << child
      end
    end
  end
end
