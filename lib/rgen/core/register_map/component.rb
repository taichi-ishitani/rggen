module RGen
  module RegisterMap
    class Component < InputBase::Component
      include Base::HierarchicalAccessors

      def initialize(parent = nil)
        super(parent)
        define_hierarchical_accessors
      end
    end
  end
end
