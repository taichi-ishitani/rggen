module RgGen
  module CUtility
    class VariableDeclaration
      def initialize(attributes)
        @attributes = attributes
      end

      def to_s
        [
          data_type, identifier, default_value_assignment
        ].compact.join(' ')
      end

      private

      def data_type
        @attributes[:data_type]
      end

      def identifier
        "#{@attributes[:name]}#{dimensions}"
      end

      def dimensions
        return unless @attributes.key?(:dimensions)
        @attributes[:dimensions].map { |d| "[#{d}]" }.join
      end

      def default_value_assignment
        return unless @attributes.key?(:default)
        "= #{@attributes[:default]}"
      end
    end
  end
end
