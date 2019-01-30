module RgGen
  module VerilogUtility
    class ClassDefinition < StructureDefinition
      attr_setter :base
      attr_setter :parameters
      attr_setter :variables

      private

      def header_code
        code_block do |code|
          code << :class << space << @name
          parameters? && paraemter_declarations(code)
          @base && (code << space <<:extends << space << @base)
          code << semicolon
        end
      end

      def body_code_blocks
        blocks = []
        variables? && (blocks << variables_declarations)
        blocks.concat(super)
        blocks
      end

      def footer_code
        :endclass
      end

      def parameters?
        !(@parameters.nil? || @parameters.empty?)
      end

      def variables?
        !(@variables.nil? || @variables.empty?)
      end

      def paraemter_declarations(code)
        wrap(code, '#(', ')') do
          indent(code, 2) do
            @parameters.each_with_index do |d, i|
              code << comma << nl if i > 0
              code << d
            end
          end
        end
      end

      def variables_declarations
        lambda do |code|
          variables.each { |variable| code << variable << semicolon << nl }
        end
      end
    end
  end
end
