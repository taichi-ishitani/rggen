module RGen
  module GeneratorBase
    class Item < Base::Item
      include Base::HierarchicalItemAccessors
      include TemplateUtility

      class CodeGenerator
        def initialize(kind, options, body)
          @kind     = kind
          @options  = options
          @body     = body
        end

        def generate_code(item, kind, buffer)
          return if kind != @kind
          item.generator.create_context if @options[:create_context]
          item.instance_exec(buffer, &@body)
        end
      end

      class FileWriter
        def initialize(name_pattern, body)
          @name_pattern = BabyErubis::Text.new.from_str(name_pattern)
          @body         = body
        end

        def write_file(item, outptu_directory)
          code  = generate_code(item)
          path  = file_path(item, outptu_directory)
          File.write(path, code)
        end

        private

        def generate_code(item)
          buffer  = []
          item.instance_exec(buffer, &@body)
          buffer.join
        end

        def file_path(item, outptu_directory)
          path  = [outptu_directory, file_name(item)].reject(&:empty?)
          File.join(*path)
        end

        def file_name(item)
          @name_pattern.render(item)
        end
      end

      define_helpers do
        attr_reader :code_generator
        attr_reader :file_writer

        def generate_code(kind, options = {}, &body)
          @code_generator ||= CodeGenerator.new(kind, options, body)
        end

        def write_file(name_pattern, &body)
          @file_writer  ||= FileWriter.new(name_pattern, body)
        end
      end

      def initialize(generator)
        super(generator)
        define_hierarchical_item_accessors
      end

      attr_accessor :configuration
      attr_accessor :source

      class_delegator :code_generator
      class_delegator :file_writer

      alias_method  :generator, :owner

      def generate_code(kind, buffer)
        return if code_generator.nil?
        code_generator.generate_code(self, kind, buffer)
      end

      def write_file(output_directory = '')
        return if file_writer.nil?
        file_writer.write_file(self, output_directory)
      end

      private

      def __start_position
        generator.context
      end
    end
  end
end
