module RGen
  module RegisterMap
    class Component < InputBase::Component
      include Base::HierarchicalAccessor

      def initialize(parent = nil)
        super(parent)
        define_hierarchical_accessor
      end
    end
  end
end
