module RGen
  module Rtl
    module Verilog
      private

      [:wire, :reg, :logic].each do |type|
        define_method(type) do |name, signal_attributes = {}|
          signal_attributes[:type]  = type
          [
            Identifier.new(name),
            SignalDeclaration.new(name, signal_attributes)
          ]
        end
        private type
      end

      [:input, :output].each do |direction|
        define_method(direction) do |name, port_attributes = {}|
          port_attributes[:direction] = direction
          [
            Identifier.new(name),
            PortDeclaration.new(name, port_attributes)
          ]
        end
        private direction
      end

      [:parameter, :localparam].each do |type|
        define_method(type) do |name, default_value|
          [
            Identifier.new(name),
            ParameterDeclaration.new(name, type, default_value)
          ]
        end
        private type
      end

      def assign(lhs, rhs)
        "assign #{lhs} = #{rhs};"
      end

      def concat(expression, *other_expressions)
        expressions = Array[expression, *other_expressions]
        "{#{expressions.join(', ')}}"
      end

      def bin(value, width)
        sprintf("%d'b%0*b", width, width, value)
      end

      def dec(value, width)
        sprintf("%d'd%d", width, value)
      end

      def hex(value, width)
        print_width = (width + 3) / 4
        sprintf("%d'h%0*x", width, print_width, value)
      end
    end
  end
end
