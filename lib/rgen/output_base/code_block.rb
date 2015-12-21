module RGen
  module OutputBase
    class CodeBlock
      def initialize
        @lines  = []
        @indent = 0
        add_newline
      end

      attr_reader :indent

      def indent=(value)
        @indent             = value
        @lines.last.indent  = @indent
      end

      def <<(other)
        case other
        when CodeBlock
          merge_code_block(other)
        when :newline
          add_newline
        else
          @lines.last << other
        end
        self
      end

      def to_s
        @lines.map(&:to_s).join("\n")
      end

      private

      def add_newline
        line        = Line.new
        line.indent = @indent
        @lines << line
      end

      def merge_code_block(other_block)
        other_block.lines.each do |line|
          line.indent += @indent
        end
        @lines.concat(other_block.lines)
        add_newline
      end

      protected

      def lines
        @lines
      end
    end
  end
end
