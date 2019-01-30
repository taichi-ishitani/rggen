module RgGen
  module VerilogUtility
    class InterfacePort
      def initialize(attributes)
        @attributes = attributes
      end

      def to_s
        "#{interface_type} #{port_identifier}"
      end

      def identifier
        Identifier.new(@attributes[:name], nil, nil, nil)
      end

      private

      def interface_type
        return @attributes[:type] unless @attributes[:modport]
        "#{@attributes[:type]}.#{@attributes[:modport]}"
      end

      def port_identifier
        "#{@attributes[:name]}#{dimensions}"
      end

      def dimensions
        return unless @attributes[:dimensions]
        @attributes[:dimensions].map { |d| "[#{d}]" }.join
      end
    end
  end
end
