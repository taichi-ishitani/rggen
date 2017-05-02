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

      def method_missing(name, *args)
        return super if args.size > 0
        return super unless name =~ variable_name
        Identifier.new("#{@name}.#{name}")
      end

      def respond_to_missing?(symbol, include_private)
        return true if name =~ variable_name
        super
      end
    end
  end
end
