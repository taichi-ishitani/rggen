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
        when /\n/
          add_multiple_lines_string(other)
        when :newline
          add_newline
        else
          @lines.last << other
        end
        self
      end

      def to_s
        @lines.map(&:to_s).each(&:rstrip!).join("\n")
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
        if other_block.lines.last.empty?
          @lines.last.indent  = @indent
        else
          add_newline
        end
      end

      def add_multiple_lines_string(other_string)
        other_string.each_line.with_index do |line, i|
          add_newline if i > 0
          @lines.last << line
        end
        add_newline if other_string.end_with?("\n")
      end

      protected

      def lines
        @lines
      end
    end
  end
end
