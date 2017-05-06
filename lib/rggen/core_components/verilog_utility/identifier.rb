module RgGen
  module VerilogUtility
    class Identifier
      include InputBase::RegxpPatterns

      def initialize(name)
        @name = name
      end

      def to_s
        @name.to_s
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

      TYPE_CONVERSIONS  = [
        :to_a, :to_ary, :to_hash, :to_int, :to_io, :to_proc, :to_regexp, :to_str
      ].freeze

      def method_missing(name, *args)
        return super if args.size > 0
        return super if TYPE_CONVERSIONS.include?(name)
        return super unless name =~ variable_name
        Identifier.new("#{@name}.#{name}")
      end

      def respond_to_missing?(symbol, include_private)
        return super if TYPE_CONVERSIONS.include?(symbol)
        return super unless symbol =~ variable_name
        true
      end
    end
  end
end
