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

      def last_line_empty?
        lines.empty? || lines.last.empty?
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
        other_block.lines.each_with_index do |line, i|
          line.indent += @indent
          if i == 0
            @lines.last.indent  = line.indent if last_line_empty?
            @lines.last.words.concat(line.words)
          else
            @lines << line
          end
        end
        @lines.last.indent  = @indent if other_block.last_line_empty?
      end

      def add_multiple_lines_string(other_string)
        other_string.each_line.with_index do |line, i|
          add_newline if i > 0
          @lines.last << line
        end
        add_newline if other_string.end_with?("\n")
      end

      attr_reader :lines
      protected :lines
    end
  end
end
