module RgGen
  module OutputBase
    class Item < Base::Item
      include Base::HierarchicalItemAccessors
      include CodeUtility

      class CodeGenerator
        def []=(kind, body)
          @bodies ||= {}
          @bodies[kind] = body
        end

        def generate_code(item, kind, buffer)
          return unless @bodies && @bodies.key?(kind)
          if @bodies[kind].arity.zero?
            buffer << item.instance_exec(&@bodies[kind])
          else
            item.instance_exec(buffer, &@bodies[kind])
          end
        end

        def copy
          CodeGenerator.new.tap do |g|
            g.instance_variable_set(:@bodies, Hash[@bodies]) if @bodies
          end
        end
      end

      class FileWriter
        def initialize(name_pattern, body)
          @name_pattern = BabyErubis::Text.new.from_str(name_pattern)
          @body         = body
        end

        def write_file(item, outptu_directory)
          path  = file_path(item, outptu_directory)
          code  = generate_code(item, path)
          File.binwrite(path.to_s, code.to_s)
        end

        private

        def generate_code(item, path)
          CodeBlock.new.tap do |c|
            case @body.arity
            when 0
              c << item.instance_exec(&@body)
            when 1
              c << item.instance_exec(path, &@body)
            else
              item.instance_exec(path, c, &@body)
            end
          end
        end

        def file_path(item, outptu_directory)
          Pathname.new(
            File.join([outptu_directory, file_name(item)].reject(&:empty?))
          )
        end

        def file_name(item)
          @name_pattern.render(item)
        end
      end

      define_helpers do
        attr_reader :builders
        attr_reader :pre_code_generator
        attr_reader :code_generator
        attr_reader :post_code_generator
        attr_reader :file_writer

        def build(&body)
          @builders ||= []
          @builders << body
        end

        def template_engine(engine)
          define_method(:template_engine) { engine.instance }
        end

        def generate_pre_code(kind, &body)
          @pre_code_generator ||= CodeGenerator.new
          @pre_code_generator[kind] = body
        end

        def generate_code(kind, &body)
          @code_generator ||= CodeGenerator.new
          @code_generator[kind] = body
        end

        def generate_code_from_template(kind, path = nil)
          call_info = caller.first
          generate_code(kind) do
            template_engine.process_template(self, path, call_info)
          end
        end

        def generate_post_code(kind, &body)
          @post_code_generator  ||= CodeGenerator.new
          @post_code_generator[kind]  = body
        end

        def write_file(name_pattern, &body)
          @file_writer  ||= FileWriter.new(name_pattern, body)
        end

        def export(*exporting_methods)
          exported_methods.concat(
            exporting_methods.reject(&exported_methods.method(:include?))
          )
        end

        def exported_methods
          @exported_methods ||= []
        end
      end

      def self.inherited(subclass)
        super(subclass)
        [:@builders, :@exported_methods].each do |v|
          subclass.inherit_class_instance_variable(v, self, &:dup)
        end
        [
          :@pre_code_generator,
          :@code_generator,
          :@post_code_generator
        ].each do |v|
          subclass.inherit_class_instance_variable(v, self, &:copy)
        end
      end

      def initialize(owner)
        super(owner)
        define_hierarchical_item_accessors
      end

      class_delegator :builders
      class_delegator :pre_code_generator
      class_delegator :code_generator
      class_delegator :file_writer
      class_delegator :post_code_generator
      class_delegator :exported_methods

      def build
        return if builders.nil?
        builders.each do |builder|
          instance_exec(&builder)
        end
      end

      def generate_pre_code(kind, buffer)
        return if pre_code_generator.nil?
        pre_code_generator.generate_code(self, kind, buffer)
      end

      def generate_code(kind, buffer)
        return if code_generator.nil?
        code_generator.generate_code(self, kind, buffer)
      end

      def generate_post_code(kind, buffer)
        return if post_code_generator.nil?
        post_code_generator.generate_code(self, kind, buffer)
      end

      def write_file(output_directory = '')
        return if file_writer.nil?
        file_writer.write_file(self, output_directory)
      end

      private

      def process_template(path = nil)
        template_engine.process_template(self, path, caller.first)
      end

      def configuration
        @owner.configuration
      end
    end
  end
end
