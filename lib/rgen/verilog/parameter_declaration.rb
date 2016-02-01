module RGen
  module Verilog
    class ParameterDeclaration
      def initialize(name, attributes = {})
        @name           = name
        @type           = attributes[:type]
        @default_value  = (attributes[:default_value] || 0)
      end

      attr_reader :name
      attr_reader :type
      attr_reader :default_value
    end
  end
end
