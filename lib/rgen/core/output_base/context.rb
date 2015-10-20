module RGen
  module OutputBase
    class Context
      include Base::HierarchicalStructure
      include Base::HierarchicalAccessors

      def initialize(parent, level)
        super(parent)
        @level  = level
        define_hierarchical_accessors
      end
    end
  end
end
