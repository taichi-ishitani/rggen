module RgGen
  module VerilogUtility
    class InterfaceInstance
      def initialize(attributes)
        @attributes = attributes
      end

      def to_s
        "#{interface_type} #{identifier}()"
      end

      private

      def interface_type
        return @attributes[:type] unless @attributes[:parameters]
        "#{@attributes[:type]} #{parameters}"
      end

      def parameters
        "#(#{@attributes[:parameters].join(', ')})"
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
