module RgGen
  module RegisterMap
    class Component < InputBase::Component
      include Base::HierarchicalAccessors

      def initialize(parent, configuration)
        super(parent)
        @configuration  = configuration
        define_hierarchical_accessors
      end

      attr_reader :configuration
    end
  end
end
