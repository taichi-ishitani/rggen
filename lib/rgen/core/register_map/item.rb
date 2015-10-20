module RGen
  module RegisterMap
    class Item < InputBase::Item
      include Base::HierarchicalItemAccessors

      attr_reader :configuration

      def initialize(owner)
        super(owner)
        define_hierarchical_item_accessors
      end

      def build(configuration, cell)
        @configuration  = configuration
        @position       = cell.position
        super(cell.value)
      end

      private

      def error(message)
        fail RGen::RegisterMapError.new(message, @position)
      end
    end
  end
end
