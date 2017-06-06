module RgGen
  module CodeUtility
    def create_blank_code
      CodeBlock.new
    end

    private

    def newline
      :newline
    end

    alias_method :nl, :newline

    def comma
      ','
    end

    def semicolon
      ';'
    end

    def space(size = 1)
      ' ' * size
    end

    def string(expression)
      "\"#{expression}\""
    end

    def code_block(indent_size = 0)
      CodeBlock.new.tap do |code|
        code.indent = indent_size
        yield(code) if block_given?
      end
    end

    def indent(code_block, indent_size)
      code_block << nl unless code_block.last_line_empty?
      code_block.indent += indent_size
      yield if block_given?
      code_block << nl unless code_block.last_line_empty?
      code_block.indent -= indent_size
    end

    def wrap(code_block, head, tail)
      code_block << head
      yield if block_given?
      code_block << tail
    end

    def loop_index(level)
      level.times.with_object('i') { |_, index| index.next! }
    end
  end
end
