module RGen
  module Rtl
    class PortDeclaration < SignalDeclaration
      def initialize(name, port_attributes = {})
        super(name, port_attributes)
        @direction  = port_attributes[:direction] || ''
      end

      attr_reader :direction
    end
  end
end
