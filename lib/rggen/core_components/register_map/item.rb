module RgGen
  module RegisterMap
    class Item < InputBase::Item
      include Base::HierarchicalItemAccessors
      include RaiseError

      attr_reader :position

      def initialize(owner)
        super(owner)
        define_hierarchical_item_accessors
      end

      def build(cell)
        @position = cell.position
        super(cell.value)
      end

      private

      def configuration
        @owner.configuration
      end
    end
  end
end
