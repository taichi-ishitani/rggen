module RgGen
  module RAL
    class Component < OutputBase::Component
      def build
        super
        @items.each do |item|
          def_object_delegators(item, *item.identifiers)
        end
      end

      def variable_declarations(domain)
        [*@items, *@children].flat_map do |item_or_child|
          item_or_child.variable_declarations(domain)
        end
      end

      def parameter_declarations(domain)
        [*@items, *@children].flat_map do |item_or_child|
          item_or_child.parameter_declarations(domain)
        end
      end
    end
  end
end
