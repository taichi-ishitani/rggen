module RgGen
  module OutputBase
    class Item < Base::Item
      include Base::HierarchicalItemAccessors
      include CodeUtility

      CODE_GENERATION_METHODS = {
        pre:  :generate_pre_code,
        main: :generate_code,
        post: :generate_post_code
      }

      define_helpers do
        attr_reader :builders
        attr_reader :file_writer

        def build(&body)
          @builders ||= []
          @builders << body
        end

        def template_engine(engine)
          define_method(:template_engine) { engine.instance }
        end

        def code_generators
          @code_generators ||= Hash.new { |h, k| h[k] = CodeGenerator.new }
        end

        CODE_GENERATION_METHODS.each do |key, method_name|
          define_method(method_name) do |kind, &body|
            code_generators[key][kind]  = body
          end
        end

        def generate_code_from_template(kind, path = nil)
          call_info = caller.first
          generate_code(kind) do
            template_engine.process_template(self, path, call_info)
          end
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
        if @code_generators && @code_generators.size > 0
          subclass.instance_variable_set(
            :@code_generators,
            Hash[*@code_generators.flat_map { |k, g| [k, g.copy] }]
          )
        end
      end

      def initialize(owner)
        super(owner)
        define_hierarchical_item_accessors
      end

      class_delegator :builders
      class_delegator :code_generators
      class_delegator :file_writer
      class_delegator :exported_methods

      def build
        return if builders.nil?
        builders.each do |builder|
          instance_exec(&builder)
        end
      end

      def create_blank_code
        CodeBlock.new
      end

      CODE_GENERATION_METHODS.each do |key, method_name|
        define_method(method_name) do |kind, code|
          return code unless code_generators.key?(key)
          code_generators[key].generate_code(self, kind, code)
        end
      end

      def write_file(output_directory = nil)
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
