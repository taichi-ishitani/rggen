module RGen::Builder
  class Category
    def initialize
      @item_stores  = {}
    end

    def add_item_store(component_name, item_store)
      return if @item_stores.key?(component_name)
      @item_stores[component_name]  = item_store
      define_definition_method(component_name, item_store)
    end

    def define_simple_item(item_name, &body)
      do_definition(:define_simple_item, item_name, &body)
    end

    def define_list_item(list_name, item_name = nil, &body)
      do_definition(:define_list_item, list_name, item_name, &body)
    end

    def shared_context(&body)
      unless instance_variable_defined?(:@shared_context)
        @shared_context = Object.new
        @arguments.push(@shared_context)
      end
      @shared_context.singleton_class.class_exec(&body) if block_given?
    end

    def enable(*list_name, item_or_items)
      @item_stores.each_value do |item_registry|
        item_registry.enable(*list_name, item_or_items)
      end
    end

    private

    def define_definition_method(component_name, item_store)
      define_singleton_method(component_name) do |&body|
        item_store.__send__(@definition_method, *@arguments, &body)
      end
    end

    def do_definition(register_method, *arguments, &body)
      @definition_method  = register_method
      @arguments          = arguments.compact
      instance_exec(&body)
      remove_instance_variable(:@definition_method)
      remove_instance_variable(:@arguments)
      remove_instance_variable(:@shared_context)  if @shared_context
    end
  end
end
