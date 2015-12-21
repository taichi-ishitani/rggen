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
        @words.join.indent(@indent)
      end
    end
  end
end
