module RGen
  module Rtl
    class Component < OutputBase::Component
      include SingleForwardable

      def add_item(item)
        super(item)
        def_object_delegators(@items.last, *item.identifiers)
      end

      def signal_declarations
        [*@items, *@children].flat_map(&:signal_declarations)
      end

      def port_declarations
        [*@items, *@children].flat_map(&:port_declarations)
      end

      def parameter_declarations
        [*@items, *@children].flat_map(&:parameter_declarations)
      end

      def localparam_declarations
        [*@items, *@children].flat_map(&:localparam_declarations)
      end
    end
  end
end
