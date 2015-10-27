module RGen
  module OutputBase
    class Item < Base::Item
      include Base::HierarchicalItemAccessors
      include TemplateUtility

      class CodeGenerator
        def []=(kind, body)
          @bodies ||= {}
          @bodies[kind] = body
        end

        def generate_code(item, kind, buffer)
          return unless @bodies && @bodies.key?(kind)
          item.instance_exec(buffer, &@bodies[kind])
        end

        def copy
          g = CodeGenerator.new
          g.instance_variable_set(:@bodies, Hash[@bodies]) if @bodies
          g
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
        attr_reader :builders
        attr_reader :code_generator
        attr_reader :file_writer

        def build(&body)
          @builders ||= []
          @builders << body
        end

        def generate_code(kind, &body)
          @code_generator ||= CodeGenerator.new
          @code_generator[kind] = body
        end

        def write_file(name_pattern, &body)
          @file_writer  ||= FileWriter.new(name_pattern, body)
        end
      end

      def self.inherited(subclass)
        {
          :@builders       => builders       && Array.new(builders),
          :@code_generator => code_generator && code_generator.copy
        }.each do |k, v|
          subclass.instance_variable_set(k, v) if v
        end
      end

      def initialize(owner)
        super(owner)
        define_hierarchical_item_accessors
      end

      attr_reader :configuration
      attr_reader :source

      class_delegator :builders
      class_delegator :code_generator
      class_delegator :file_writer

      def build(configuration, source)
        @configuration  = configuration
        @source         = source
        builders.each do |builder|
          instance_exec(&builder)
        end unless builders.nil?
      end

      def generate_code(kind, buffer)
        return if code_generator.nil?
        code_generator.generate_code(self, kind, buffer)
      end

      def write_file(output_directory = '')
        return if file_writer.nil?
        file_writer.write_file(self, output_directory)
      end
    end
  end
end
