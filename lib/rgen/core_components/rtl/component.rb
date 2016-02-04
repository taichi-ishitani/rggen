module RGen
  module RTL
    class Component < OutputBase::Component
      def build
        super
        @items.each do |item|
          def_object_delegators(item, *item.identifiers)
        end
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
