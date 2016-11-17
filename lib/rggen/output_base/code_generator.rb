module RgGen
  module OutputBase
    class CodeGenerator
      def []=(kind, body)
        (@bodies ||= {})[kind]  = body
      end

      def generate_code(context, kind, code)
        return code unless body?(kind)
        (code || context.create_blank_code).tap do |c|
          execute_body(context, kind, c)
        end
      end

      def copy
        CodeGenerator.new.tap do |g|
          g.instance_variable_set(:@bodies, Hash[@bodies]) if @bodies
        end
      end

      private

      def body?(kind)
        @bodies && @bodies.key?(kind)
      end

      def execute_body(context, kind, code)
        if @bodies[kind].arity.zero?
          code << context.instance_exec(&@bodies[kind])
        else
          context.instance_exec(code, &@bodies[kind])
        end
      end
    end
  end
end
