module RgGen
  module CodeUtility
    class Line
      def initialize
        @words      = []
        @not_empty  = false
        @indent     = 0
      end

      attr_reader   :words
      attr_accessor :indent

      def <<(word)
        @words << word.to_s
        self
      end

      def empty?
        @words.all?(&:empty?)
      end

      def to_s
        return '' if @words.empty?
        @words.join.indent(@indent)
      end
    end
  end
end
