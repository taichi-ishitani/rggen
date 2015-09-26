module RGen::Builder
  class ListItemEntry
    def initialize(item_base, factory_base, *contexts, &body)
      @item_base      = Class.new(item_base)
      @factory        = Class.new(factory_base)
      @items          = {}
      @enabled_items  = []
      instance_exec(*contexts, &body) if block_given?
    end

    def item_base(&body)
      @item_base.class_exec(&body)  if block_given?
      @item_base
    end

    def factory(&body)
      @factory.class_exec(&body)  if block_given?
      @factory
    end

    def define_list_item(item_name, *contexts, &body)
      @items[item_name] = Class.new(item_base)
      @items[item_name].class_exec(*contexts, &body)
    end

    def enable(item_or_items)
      Array(item_or_items).each do |item|
        next unless @items.key?(item)
        next if @enabled_items.include?(item)
        @enabled_items  << item
      end
    end

    def build_factory
      f               = @factory.new
      f.target_items  = target_items
      f
    end

    private

    def target_items
      @enabled_items.each_with_object({}) do |item_name, items|
        items[item_name]  = @items[item_name]
      end
    end
  end
end
