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
          @body = block if block_given?
        end

        def to_code
          code_block do |code|
            code << header_code << nl
            body_code(code) unless @body.nil?
            code << footer_code << nl
          end
        end

        private

        def body_code(code)
          indent(code, 2) do
            if @body.arity.zero?
              code << @body.call
            else
              @body.call(code)
            end
          end
        end
      end
    end
  end
end
