module RGen
  module OutputBase
    class Line
      def initialize
        @words  = []
        @indent = 0
      end

      attr_writer :indent

      def <<(word)
        @words << word
      end

      def to_s
        @words.join.indent(@indent)
      end
    end
  end
end
