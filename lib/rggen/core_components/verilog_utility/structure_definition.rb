module RgGen
  module VerilogUtility
    class StructureDefinition
      include CodeUtility

      def initialize(name)
        @name = name
        yield(self) if block_given?
      end

      def body(&block)
        @bodies ||= []
        @bodies << block if block_given?
      end

      def to_code
        code_block do |code|
          code << header_code << nl
          body_code(code) if body_code?
          code << footer_code << nl
        end
      end

      private

      def body_code(code)
        body_code_blocks.each do |body|
          generate_body_code(code, body)
        end
      end

      def body_code_blocks
        @bodies || []
      end

      def generate_body_code(code, body)
        indent(code, 2) do
          if body.arity.zero?
            code << body.call
          else
            body.call(code)
          end
        end
      end

      def body_code?
        !(@bodies.nil? || @bodies.empty?)
      end
    end
  end
end
