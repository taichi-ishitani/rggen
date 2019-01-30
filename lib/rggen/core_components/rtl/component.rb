module RgGen
  module RTL
    class Component < OutputBase::Component
      def build
        super
        @items.each do |item|
          def_object_delegators(item, *item.identifiers)
        end
      end

      def signal_declarations(domain)
        [*@items, *@children].flat_map { |o| o.signal_declarations(domain) }
      end

      def port_declarations(domain)
        [*@items, *@children].flat_map { |o| o.port_declarations(domain) }
      end

      def parameter_declarations(domain)
        [*@items, *@children].flat_map { |o| o.parameter_declarations(domain) }
      end
    end
  end
end
