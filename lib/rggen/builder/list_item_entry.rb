module RgGen
  module Builder
    class ListItemEntry
      def initialize(item_base, factory_base, context, &body)
        @item_base      = Class.new(item_base)
        @factory        = Class.new(factory_base)
        @items          = {}
        @enabled_items  = []
        unless context.nil?
          set_context(@item_base     , context)
          set_context(@factory       , context)
          set_context(singleton_class, context)
        end
        instance_exec(&body) if block_given?
      end

      def item_base(&body)
        @item_base.class_exec(&body) if block_given?
        @item_base
      end

      def item_class(&body)
        @item_class ||= Class.new(@item_base)
        @item_class.class_exec(&body) if block_given?
        @item_class
      end

      alias_method :default_item, :item_class

      def factory(&body)
        @factory.class_exec(&body) if block_given?
        @factory
      end

      def define_list_item(item_name, context, &body)
        klass = Class.new(item_base)
        unless context.nil?
          if item_base.private_method_defined?(:shared_context)
            fail BuilderError, 'base class already has #shared_context'
          end
          set_context(klass, context)
        end
        klass.class_exec(&body)
        @items[item_name] = klass
      end

      def enable(item_or_items)
        Array(item_or_items).each do |item|
          next unless @items.key?(item)
          next if @enabled_items.include?(item)
          @enabled_items  << item
        end
      end

      def build_factory
        @factory.new.tap do |f|
          f.target_items  = target_items
          f.target_item   = @item_class unless @item_class.nil?
        end
      end

      private

      def target_items
        return nil if @enabled_items.empty?
        @enabled_items.each_with_object({}) do |item_name, items|
          items[item_name]  = @items[item_name]
        end
      end

      def set_context(klass, context)
        klass.class_exec do
          define_method(:shared_context) do
            context
          end
          private :shared_context
        end
      end
    end
  end
end
