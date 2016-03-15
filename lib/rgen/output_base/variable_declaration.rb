module RGen
  module OutputBase
    class VariableDeclaration
      def initialize(declation_type, attributes)
        @declation_type = declation_type
        @attributes     = attributes
      end

      def to_s
        code_snippets.join(' ')
      end

      private

      def code_snippets
        [
          random_or_direction_or_parameter_type,
          data_type,
          width,
          identifier,
          default_value_assignment
        ].reject(&:empty?)
      end

      def random_or_direction_or_parameter_type
        case @declation_type
        when :variable
          (@attributes[:random] && 'rand') || ''
        when :port
          @attributes[:direction] || ''
        when :parameter
          @attributes[:parameter_type]
        end
      end

      def data_type
        @attributes[:data_type] || ''
      end

      def width
        return '' if @attributes[:width].nil?
        return '' if (variable? || port?) && @attributes[:width] == 1
        "[#{@attributes[:width] - 1}:0]"
      end

      def identifier
        "#{@attributes[:name]}#{dimensions}"
      end

      def dimensions
        return '' if @attributes[:dimensions].nil?
        @attributes[:dimensions].map { |dimension| "[#{dimension}]" }.join
      end

      def default_value_assignment
        (@attributes[:default].nil? && '') || "= #{@attributes[:default]}"
      end

      def variable?
        @declation_type == :variable
      end

      def port?
        @declation_type == :port
      end
    end
  end
end
