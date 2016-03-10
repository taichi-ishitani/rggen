module RGen
  module OutputBase
    class SubroutineDefinition < CodeBlock
      def initialize(type, name, &body)
        super()
        @type = type
        body.call(self)
        build_subroutine_code(name)
      end

      def return_type(data_type_and_width)
        if [Symbol, String].any?(&data_type_and_width.method(:is_a?))
          @return_type  = data_type_and_width
        else
          data_type     = data_type_and_width[:data_type]
          width         = data_type_and_width[:width    ] || 1
          @return_type  =
            ((width > 1) && "#{data_type} [#{width - 1}:0]") || data_type
        end
      end

      def arguments(args)
        @arguments  = args
      end

      def body(&block)
        @body = block
      end

      private

      def build_subroutine_code(name)
        header_code(name)
        body_code
        footer_code
      end

      def code
        self
      end

      def function?
        @type == :function
      end

      def header_code(name)
        code << [
          (function? && :function   ) || :task,
          (function? && @return_type) || nil,
          "#{name}(#{Array(@arguments).join(', ')});"
        ].compact.join(' ')
        code << :newline
      end

      def body_code
        return if @body.nil?
        indenting do
          if @body.arity == 0
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

      def footer_code
        code << (function? && :endfunction) || :endtask
        code << :newline
      end
    end
  end
end
