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

      def build
        items.each(&:build)
        children.each(&:build)
      end

      def generate_code(kind, mode, buffer = nil)
        output_code = buffer.nil?
        buffer      = buffer || CodeBlock.new
        generate_code_main(kind, mode, buffer)
        buffer.to_s if output_code
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

      def generate_code_main(kind, mode, buffer)
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

      def output_directory(root_directory)
        File.join([root_directory, @output_directory.to_s].reject(&:empty?))
      end
    end
  end
end