module RGen
  module OutputBase
    module CodeUtility
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

      def indent(size, &block)
        code        = CodeBlock.new
        code.indent = size
        block.call(code)
        code
      end

      def loop_index(level)
        level.times.with_object('i') { |_, index| index.next! }
      end
    end
  end
end
