module RGen::Builder
  class ItemRegistry
    def initialize(base, factory)
      @base               = base
      @factory            = factory
      @value_item_entries = {}
      @list_item_entries  = {}
      @enabled_items      = []
    end

    attr_reader :base
    attr_reader :factory

    def register_value_item(item_name, &body)
      @list_item_entries.delete(item_name)
      @value_item_entries[item_name]  = ValueItemEntry.new(base, body, factory)
    end

    def register_list_item(list_name, item_name = nil, &body)
      if item_name.nil?
        @value_item_entries.delete(list_name)
        @list_item_entries[list_name] = ListItemEntry.new(base, factory)
        @list_item_entries[list_name].instance_exec(&body)
      else
        @list_item_entries[list_name].register_list_item(item_name, &body)
      end
    end

    def enable(*list_name, item_or_items)
      case list_name.size
      when 0
        Array(item_or_items).each do |item|
          next if @enabled_items.include?(item)
          next unless @value_item_entries.key?(item) ||
                      @list_item_entries.key?(item)
          @enabled_items  << item
        end
      when 1
        @list_item_entries[list_name[0]].enable(item_or_items)
      end
    end

    def build_factories
      @enabled_items.each_with_object({}) do |name, factories|
        entry           = @value_item_entries[name] || @list_item_entries[name]
        factories[name] = entry.build_factory
      end
    end
  end
end
