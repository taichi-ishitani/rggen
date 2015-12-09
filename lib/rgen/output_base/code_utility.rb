module RGen
  module OutputBase
    module CodeUtility
      private

      def newline
        "\n"
      end

      alias_method :nl, :newline

      def space(size = 1)
        ' ' * size
      end

      def indent(size, &block)
        buffer  = []
        block.call(buffer)
        buffer.join.each_line.with_object('') do |line, indented_code|
          if line =~ /^\s*$/
            indented_code << nl
          else
            indented_code << space(size) << line
          end
        end
      end
    end
  end
end
