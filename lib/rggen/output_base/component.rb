module RgGen
  module OutputBase
    class Component < Base::Component
      include Base::HierarchicalAccessors

      def initialize(parent, configuration, source)
        super(parent)
        define_hierarchical_accessors
        @configuration  = configuration
        @source         = source
        @need_children  = source.need_children?
        def_delegators(:source, *source.fields)
      end

      attr_reader :configuration
      attr_reader :source
      attr_writer :output_directory

      def add_item(item)
        super(item)
        def_object_delegators(@items.last, *item.exported_methods)
      end

      def build
        items.each(&:build)
        children.each(&:build)
      end

      def generate_code(kind, mode, code = nil)
        [
          pre_code_generator, *main_code_generator(mode), post_code_generator
        ].inject(code) { |c, g| g.call(kind, mode, c) }
      end

      def write_file(output_directory)
        directoris  = [*Array(output_directory), @output_directory].compact
        [*items, *children].each do |item_or_child|
          item_or_child.write_file(directoris)
        end
      end

      private

      def generate_item_code(method_name, kind, _, code)
        items.inject(code) do |c, item|
          item.send(method_name, kind, c)
        end
      end

      def generate_child_code(kind, mode, code)
        children.inject(code) do |c, child|
          child.generate_code(kind, mode, c)
        end
      end

      def pre_code_generator
        method(:generate_item_code).curry[:generate_pre_code]
      end

      def main_code_generator(mode)
        {
          top_down: [
            method(:generate_item_code ).curry[:generate_code],
            method(:generate_child_code)
          ],
          bottom_up: [
            method(:generate_child_code),
            method(:generate_item_code ).curry[:generate_code]
          ]
        }[mode]
      end

      def post_code_generator
        method(:generate_item_code).curry[:generate_post_code]
      end
    end
  end
end
