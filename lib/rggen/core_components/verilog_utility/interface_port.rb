module RgGen
  module VerilogUtility
    class InterfacePort
      def initialize(attributes)
        @attributes = attributes
      end

      def to_s
        "#{interface_type} #{identifier}"
      end

      private

      def interface_type
        return @attributes[:type] unless @attributes[:modport]
        "#{@attributes[:type]}.#{@attributes[:modport]}"
      end

      def identifier
        "#{@attributes[:name]}#{dimensions}"
      end

      def dimensions
        return unless @attributes[:dimensions]
        @attributes[:dimensions].map { |d| "[#{d}]" }.join
      end
    end
  end
end
