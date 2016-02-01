module RGen
  module Verilog
    class Identifier
      def initialize(name)
        @name = name
      end

      def to_s
        @name
      end

      def [](indexes_or_msb, lsb = indexes_or_msb)
        if indexes_or_msb.nil?
          self
        elsif indexes_or_msb.is_a?(Array)
          indexes_or_msb.inject(self) do |identifer, index|
            identifer[index]
          end
        elsif indexes_or_msb == lsb
          Identifier.new("#{@name}[#{indexes_or_msb}]")
        else
          Identifier.new("#{@name}[#{indexes_or_msb}:#{lsb}]")
        end
      end
    end
  end
end
