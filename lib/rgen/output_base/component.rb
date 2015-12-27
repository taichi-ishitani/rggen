module RGen
  module OutputBase
    class Component < Base::Component
      include Base::HierarchicalAccessors

      def initialize(parent, configuration, register_map)
        super(parent)
        define_hierarchical_accessors
        @configuration  = configuration
        @register_map   = register_map
        def_delegators(:@register_map, *@register_map.fields)
      end

      attr_reader :configuration
      attr_writer :output_directory

      def add_item(item)
        super(item)
        def_object_delegators(@items.last, *item.exported_methods)
      end

      def build
        items.each(&:build)
        children.each(&:build)
      end

      def generate_code(kind, mode, buffer = nil)
        buffer  ||= CodeBlock.new
        generate_pre_code(kind, buffer)
        generate_main_code(kind, mode, buffer)
        generate_post_code(kind, buffer)
        buffer
      end

      def write_file(root_directory)
        directory = output_directory(root_directory)
        FileUtils.mkpath(directory) unless Dir.exist?(directory)
        items.each do |item|
          item.write_file(directory)
        end
        children.each do |child|
          child.write_file(directory)
        end
      end

      private

      def generate_pre_code(kind, buffer)
        items.each do |item|
          item.generate_pre_code(kind, buffer)
        end
      end

      def generate_main_code(kind, mode, buffer)
        case mode
        when :top_down
          generate_item_code(kind, buffer)
          generate_child_code(kind, mode, buffer)
        when :bottom_up
          generate_child_code(kind, mode, buffer)
          generate_item_code(kind, buffer)
        end
      end

      def generate_child_code(kind, mode, buffer)
        children.each do |child|
          child.generate_code(kind, mode, buffer)
        end
      end

      def generate_item_code(kind, buffer)
        items.each do |item|
          item.generate_code(kind, buffer)
        end
      end

      def generate_post_code(kind, buffer)
        items.reverse_each do |item|
          item.generate_post_code(kind, buffer)
        end
      end

      def output_directory(root_directory)
        File.join([root_directory, @output_directory.to_s].reject(&:empty?))
      end
    end
  end
end