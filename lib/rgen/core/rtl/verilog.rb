module RGen
  module Rtl
    module Verilog
      private

      def declare_signal(type, name, signal_attributes)
        signal_attributes[:type]  = type
        [
          Identifier.new(name),
          SignalDeclaration.new(name, signal_attributes)
        ]
      end

      [:wire, :reg, :logic].each do |type|
        define_method(type) do |name, signal_attributes = {}|
          declare_signal(type, name, signal_attributes)
        end
        private type
      end

      def declare_port(direction, name, port_attributes)
        port_attributes[:direction] = direction
        [
          Identifier.new(name),
          PortDeclaration.new(name, port_attributes)
        ]
      end

      [:input, :output].each do |direction|
        define_method(direction) do |name, port_attributes = {}|
          declare_port(direction, name, port_attributes)
        end
        private direction
      end

      def declare_parameter(type, name, default_value)
        [
          Identifier.new(name),
          ParameterDeclaration.new(name, type, default_value)
        ]
      end

      [:parameter, :localparam].each do |type|
        define_method(type) do |name, default_value|
          declare_parameter(type, name, default_value)
        end
        private type
      end
    end
  end
end
