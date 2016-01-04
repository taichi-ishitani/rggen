module RGen
  module Builder
    class SimpleItemEntry
      def initialize(base, factory, context, &body)
        @item_class = define_item_class(base, context, body)
        @factory    = factory
      end

      attr_reader :item_class
      attr_reader :factory

      def build_factory
        @factory.new.tap do |f|
          f.target_item = @item_class
        end
      end

      private

      def define_item_class(base, context, body)
        klass = Class.new(base)
        klass.class_exec do
          define_method(:shared_context) do
            context
          end
          private :shared_context
        end unless context.nil?
        klass.class_exec(&body) unless body.nil?
        klass
      end
    end
  end
end
