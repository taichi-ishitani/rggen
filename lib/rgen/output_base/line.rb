module RGen
  module OutputBase
    class Line
      def initialize
        @words  = []
        @indent = 0
      end

      attr_accessor :indent

      def <<(word)
        @words << word
      end

      def to_s
        return '' if @words.empty?
        s = @words.join.indent(@indent)
        ((/\A\s*\z/ !~ s) && s) || ''
      end
    end
  end
end
