module RgGen
  module CUtility
    class DataStructureDefinition
      include CodeUtility

      def initialize(type_keyword, type_name, &body)
        @type_keyword = type_keyword
        @type_name    = type_name
        body.call(self) if block_given?
      end

      attr_setter :members

      def with_typedef(typedef_name = nil)
        @with_typedef = true
        @typedef_name = typedef_name
      end

      def to_code
        code_block do |code|
          header_code(code)
          body_code(code)
          footer_code(code)
        end
      end

      private

      def header_code(code)
        code << [
          typedef, @type_keyword, type_name, '{'
        ].compact.join(space) << nl
      end

      def body_code(code)
        indent(code, 2) do
          @members.each do |member, i|
            code << member << semicolon << nl
          end
        end
      end

      def footer_code(code)
        code << ['}', typedef_name].compact.join(space) << semicolon << nl
      end

      def typedef
        @with_typedef && :typedef
      end

      def type_name
        return @type_name unless @with_typedef
        @typedef_name && @type_name
      end

      def typedef_name
        return nil unless @with_typedef
        @typedef_name || @type_name
      end
    end
  end
end
