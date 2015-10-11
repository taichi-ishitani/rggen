module RGen::GeneratorBase
  class Item < RGen::Base::Item
    include TemplateUtility

    class FileWriter
      def initialize(name_pattern, body)
        @name_pattern = BabyErubis::Text.new.from_str(name_pattern)
        @body         = body
      end

      def write_file(context, outptu_directory)
        code  = generate_code(context)
        path  = file_path(context, outptu_directory)
        File.write(path, code)
      end

      private

      def generate_code(context)
        buffer  = []
        context.instance_exec(buffer, &@body)
        buffer.join
      end

      def file_path(context, outptu_directory)
        item  = [outptu_directory, file_name(context)].reject(&:empty?)
        File.join(*item)
      end

      def file_name(context)
        @name_pattern.render(context)
      end
    end

    define_helpers do
      attr_reader :code_generators
      attr_reader :file_writer

      def generate_code(kind, &body)
        @code_generators  ||= {}
        @code_generators[kind] = body
      end

      def write_file(name_pattern, &body)
        @file_writer  = FileWriter.new(name_pattern, body)
      end
    end

    attr_accessor :configuration
    attr_accessor :source

    class_delegator :code_generators
    class_delegator :file_writer

    alias_method  :generator, :owner

    def generate_code(kind, buffer)
      return if code_generators.nil?
      return unless code_generators.key?(kind)
      instance_exec(buffer, &code_generators[kind])
    end

    def write_file(output_directory = '')
      return if file_writer.nil?
      file_writer.write_file(self, output_directory)
    end
  end
end
