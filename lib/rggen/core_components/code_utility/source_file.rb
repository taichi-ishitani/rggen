module RgGen
  module CodeUtility
    class SourceFile
      include CodeUtility

      class << self
        attr_setter :ifndef_keyword
        attr_setter :endif_keyword
        attr_setter :define_keyword
        attr_setter :include_keyword
      end

      def initialize(path, &body)
        @path = path
        body.call(self) if block_given?
      end

      attr_reader :path

      def header(&block)
        @header_block ||= block
      end

      def include_guard(prefix = nil, suffix = prefix, &block)
        @guard_macro  ||= (
          block || method(:default_guard_macro)
        ).call(prefix, suffix)
      end

      def include_file(file)
        include_files << file
      end

      def body(&block)
        @body_block ||= block
      end

      def to_code
        code_block do |c|
          blocks.each { |b| generate_code(c, b) }
        end
      end

      def to_s
        to_code.to_s
      end

      private

      def blocks
        [
          @header_block,
          include_guard_header,
          include_files_block,
          @body_block,
          include_guard_footer
        ].compact
      end

      def include_files
        @include_files  ||= []
      end

      def default_guard_macro(prefix, suffix)
       "#{prefix}#{path.basename.to_s.upcase.gsub(/\W/, '_')}#{suffix}"
      end

      def include_guard_header
        @guard_macro && lambda do |c|
          c << "#{self.class.ifndef_keyword} #{@guard_macro}" << nl
          c << "#{self.class.define_keyword} #{@guard_macro}" << nl
        end
      end

      def include_guard_footer
        @guard_macro && lambda { |c| c << self.class.endif_keyword << nl }
      end

      def include_files_block
        @include_files && lambda do |c|
          include_files.each do |f|
            c << "#{self.class.include_keyword} #{f.to_s.quote}" << nl
          end
        end
      end

      def generate_code(code, block)
        if block.arity.zero?
          code << block.call
        else
          block.call(code)
        end
        code << nl unless code.last_line_empty?
      end
    end
  end
end
