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

    def code_block(indent_size = 0, &block)
      CodeBlock.new.tap do |code|
        code.indent = indent_size
        block.call(code) if block_given?
      end
    end

    def indent(code_block, indent_size, &indent_block)
      code_block << nl unless code_block.last_line_empty?
      code_block.indent += indent_size
      indent_block.call if block_given?
      code_block << nl unless code_block.last_line_empty?
      code_block.indent -= indent_size
    end

    def wrap(code_block, head, tail, &block)
      code_block << head
      block.call if block_given?
      code_block << tail
    end

    def loop_index(level)
      level.times.with_object('i') { |_, index| index.next! }
    end
  end
end
