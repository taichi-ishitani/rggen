module RGen
  module Rtl
    module Verilog
      class Identifier
        def initialize(name, msb = nil, lsb = msb)
          if msb && (msb != lsb)
            @name = "#{name}[#{msb}:#{lsb}]"
          elsif msb
            @name = "#{name}[#{msb}]"
          else
            @name = name
          end
        end

        def to_s
          @name
        end

        def [](msb, lsb = msb)
          Identifier.new(@name, msb, lsb)
        end
      end
    end
  end
end
