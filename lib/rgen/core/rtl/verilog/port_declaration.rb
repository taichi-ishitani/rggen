module RGen
  module Rtl
    module Verilog
      class PortDeclaration < SignalDeclaration
        def initialize(name, port_attributes = {})
          port_attributes[:type]  ||= ''
          super(name, port_attributes)
          @direction  = port_attributes[:direction].to_s
        end

        attr_reader :direction
      end
    end
  end
end
