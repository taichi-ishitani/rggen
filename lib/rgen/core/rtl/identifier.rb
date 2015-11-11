module RGen
  module Rtl
    class Identifier
      def initialize(name)
        @name = name
      end

      def to_s
        @name
      end

      def [](msb, lsb = msb)
        if msb == lsb
          Identifier.new("#{@name}[#{msb}]")
        else
          Identifier.new("#{@name}[#{msb}:#{lsb}]")
        end
      end
    end
  end
end
