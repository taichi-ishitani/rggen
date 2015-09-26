module RGen::Builder
  class ItemStore
    def initialize(base, factory)
      @base               = base
      @factory            = factory
      @value_item_entries = {}
      @list_item_entries  = {}
      @enabled_items      = []
    end

    attr_reader :base
    attr_reader :factory

    def define_value_item(item_name, *contexts, &body)
      entry = ValueItemEntry.new(base, factory, *contexts, &body)
      update_entries(:value, item_name, entry)
    end

    def define_list_item(list_name, *args, &body)
      case args.first
      when Symbol
        unless @list_item_entries.key?(list_name)
          message = "undefined list item entry: #{list_name}"
          fail RGen::BuilderError, message
        end

        item_name = args.shift
        contexts  = args
        entry     = @list_item_entries[list_name]
        entry.define_list_item(item_name, *contexts, &body)
      else
        contexts  = args
        entry     = ListItemEntry.new(base, factory, *contexts, &body)
        update_entries(:list, list_name, entry)
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
        return unless @list_item_entries.key?(list_name[0])
        @list_item_entries[list_name[0]].enable(item_or_items)
      else
        message = "wrong number of arguments (#{list_name.size + 1} for 1..2)"
        fail ArgumentError, message
      end
    end

    def build_factories
      @enabled_items.each_with_object({}) do |name, factories|
        factories[name] = (
          @value_item_entries[name] || @list_item_entries[name]
        ).build_factory
      end
    end

    private

    def update_entries(entry_type, entry_name, entry)
      if entry_type == :value
        @list_item_entries.delete(entry_name)
        @value_item_entries[entry_name] = entry
      else
        @value_item_entries.delete(entry_name)
        @list_item_entries[entry_name]  = entry
      end
    end
  end
end
