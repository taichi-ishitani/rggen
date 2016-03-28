module RGen
  module OutputBase
    module VerilogUtility
      class StructureDefinition
        include CodeUtility

        def initialize(name, &body)
          @name = name
          body.call(self) if block_given?
        end

        def body(&block)
          bodies << block if block_given?
        end

        def to_code
          code_block do |code|
            code << header_code << nl
            body_code(code) if body_code?
            code << footer_code << nl
          end
        end

        private

        def bodies
          @bodies ||= []
        end

        def body_code(code)
          bodies.each do |body|
            generate_body_code(code, body)
          end
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
          @bodies && @bodies.size > 0
        end
      end
    end
  end
end
