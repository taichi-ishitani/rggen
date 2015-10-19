module RGen
  module GeneratorBase
    class Generator < Base::Component
      attr_reader :context

      def generate_code(kind, mode, buffer)
        case mode
        when :top_down
          generate_item_code(kind, buffer)
          generate_child_code(kind, mode, buffer)
        when :bottom_up
          generate_child_code(kind, mode, buffer)
          generate_item_code(kind, buffer)
        end
      end

      def write_file(output_directory = '')
        items.each do |item|
          item.write_file(output_directory)
        end
        children.each do |child|
          child.write_file(output_directory)
        end
      end

      def create_context
        __create_context(nil)
      end

      private

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

      protected

      def __create_context(parent_context)
        @context  = Context.new(parent_context, level)
        children.each do |child|
          child.__create_context(context)
        end
      end
    end
  end
end