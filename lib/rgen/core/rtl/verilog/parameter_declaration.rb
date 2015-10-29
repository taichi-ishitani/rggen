module RGen
  module Rtl
    module Verilog
      class ParameterDeclaration
        def initialize(name, type, default_value)
          @name           = name
          @type           = type
          @default_value  = default_value
        end

        attr_reader :name
        attr_reader :type
        attr_reader :default_value
      end
    end
  end
end
