module RgGen
  module VerilogUtility
    class ModuleDefinition < StructureDefinition
      attr_setter :parameters
      attr_setter :ports
      attr_setter :signals

      def to_code
        bodies.unshift(signal_declarations) if signals?
        super
      end

      private

      def header_code
        code_block do |code|
          code << :module << space << @name << space
          parameter_declarations(code)
          port_declarations(code)
          code << semicolon
        end
      end

      def footer_code
        :endmodule
      end

      def parameters?
        !(@parameters.nil? || @parameters.empty?)
      end

      def ports?
        !(@ports.nil? || @ports.empty?)
      end

      def signals?
        !(@signals.nil? || @signals.empty?)
      end

      def parameter_declarations(code)
        return unless parameters?
        wrap(code, '#(', ')') do
          declarations(@parameters, code)
        end
      end

      def port_declarations(code)
        wrap(code, '(', ')') do
          declarations(@ports, code) if ports?
        end
      end

      def signal_declarations
        lambda do |code|
          signals.each do |signal|
            code << signal << semicolon << nl
          end
        end
      end

      def declarations(list, code)
        indent(code, 2) do
          list.each_with_index do |d, i|
            code << comma << nl if i > 0
            code << d
          end
        end
      end
    end
  end
end
