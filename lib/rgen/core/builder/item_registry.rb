module RGen::Builder
  class ItemRegistry
    def initialize(base, factory)
      @base           = base
      @factory        = factory
      @entries        = {}
      @enabled_items  = []
    end

    attr_reader :base
    attr_reader :factory

    def register_item(item_name, &body)
      entry = ValueItemEntry.new(factory)
      entry.item_class(base, &body)
      @entries[item_name] = entry
    end

    def enable(item_or_items)
      additional_items  = Array(item_or_items).reject do |item|
        @enabled_items.include?(item)
      end
      @enabled_items.concat(additional_items)
    end

    def build_factories
      @enabled_items.each_with_object({}) do |name, factories|
        factories[name] = @entries[name].build_factory if @entries.key?(name)
      end
    end
  end
end
