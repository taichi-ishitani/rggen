module RgGen
  module VerilogUtility
    class InterfaceInstance
      def initialize(attributes)
        @attributes = attributes
      end

      def to_s
        "#{interface_type} #{instance_identifier}()"
      end

      def identifier
        Identifier.new(@attributes[:name], nil, nil, nil)
      end

      private

      def interface_type
        return @attributes[:type] unless @attributes[:parameters]
        "#{@attributes[:type]} #{parameters}"
      end

      def parameters
        "#(#{@attributes[:parameters].join(', ')})"
      end

      def instance_identifier
        "#{@attributes[:name]}#{dimensions}"
      end

      def dimensions
        return unless @attributes[:dimensions]
        @attributes[:dimensions].map { |d| "[#{d}]" }.join
      end
    end
  end
end
