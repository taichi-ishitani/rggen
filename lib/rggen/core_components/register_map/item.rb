module RgGen
  module RegisterMap
    class Item < InputBase::Item
      include Base::HierarchicalItemAccessors
      include RaiseError

      attr_reader :configuration
      attr_reader :position

      def initialize(owner)
        super(owner)
        define_hierarchical_item_accessors
      end

      def build(configuration, cell)
        @configuration  = configuration
        @position       = cell.position
        super(cell.value)
      end
    end
  end
end
