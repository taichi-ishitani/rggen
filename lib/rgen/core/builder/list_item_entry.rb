module RGen::Builder
  class ListItemEntry
    def initialize(item_base, factory_base)
      @item_base      = Class.new(item_base)
      @factory        = Class.new(factory_base)
      @items          = {}
      @enabled_items  = []
    end

    def item_base(&body)
      @item_base.class_eval(&body)  if block_given?
      @item_base
    end

    def factory(&body)
      @factory.class_eval(&body)  if block_given?
      @factory
    end

    def register_list_item(item_name, &body)
      @items[item_name] = Class.new(item_base, &body)
    end

    def enable(item_or_items)
      Array(item_or_items).each do |item|
        next unless @items.key?(item) && @enabled_items.not.include?(item)
        @enabled_items  << item
      end
    end

    def build_factory
      f = @factory.new(:list_item_factory)
      @enabled_items.each do |item_name|
        f.register(@items[item_name], item_name)
      end
      f
    end
  end
end
