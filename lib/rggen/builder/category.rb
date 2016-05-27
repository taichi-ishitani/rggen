module RgGen
  module Builder
    class Category
      def initialize
        @item_stores  = {}
      end

      def add_item_store(component_name, item_store)
        return if @item_stores.key?(component_name)
        @item_stores[component_name]  = item_store
        define_definition_method(component_name)
      end

      def define_simple_item(item_name_or_names, &body)
        Array(item_name_or_names).each do |item_name|
          do_definition(:define_simple_item, item_name, &body)
        end
      end

      def define_list_item(list_name_or_names, item_name_or_names = nil, &body)
        if item_name_or_names.nil?
          Array(list_name_or_names).each do |list_name|
            do_definition(:define_list_item, list_name, nil, &body)
          end
        else
          list_name = list_name_or_names
          Array(item_name_or_names).each do |item_name|
            do_definition(:define_list_item, list_name, item_name, &body)
          end
        end
      end

      def shared_context(&body)
        @shared_context ||= Object.new
        @shared_context.singleton_class.class_exec(&body) if block_given?
      end

      def enable(*args)
        @item_stores.each_value do |item_registry|
          item_registry.enable(*args)
        end
      end

      private

      def define_definition_method(component_name)
        define_singleton_method(component_name) do |&body|
          item_store  = @item_stores[component_name]
          item_store.__send__(@definition_method, @shared_context, *@arguments, &body)
        end
      end

      def do_definition(register_method, *arguments, &body)
        @definition_method  = register_method
        @arguments          = arguments
        instance_exec(&body)
        remove_instance_variable(:@definition_method)
        remove_instance_variable(:@arguments        )
        remove_instance_variable(:@shared_context   ) if @shared_context
      end
    end
  end
end
