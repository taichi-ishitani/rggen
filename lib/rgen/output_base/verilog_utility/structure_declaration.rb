module RGen
  module OutputBase
    module VerilogUtility
      class StructureDeclaration < CodeBlock
        def initialize(name, &body)
          super()
          @name = name
          body.call(self) if block_given?
          build_code
        end

        def body(&block)
          @body = block if block_given?
        end

        private

        def build_code
          code << header_code
          code << :newline
          body_code
          code << footer_code
          code << :newline
        end

        def code
          self
        end

        def body_code
          return if @body.nil?
          indenting do
            if @body.arity.zero?
              code << @body.call
            else
              @body.call(code)
            end
          end
        end

        def indenting(&block)
          code.indent += 2
          block.call
          code << :newline unless code.last_line_empty?
          code.indent -= 2
        end
      end
    end
  end
end
