module RGen::Builder
  class ItemRegistry
    Entry = Struct.new(:name, :klass, :factory) do
      def build_factory
        f = factory.new
        f.register(name, klass)
        f
      end
    end

    def initialize(base, factory)
      @base           = base
      @factory        = factory
      @entries        = {}
      @enabled_items  = []
    end

    attr_reader :base
    attr_reader :factory

    def register_item(name, &body)
      klass           = Class.new(base, &body)
      @entries[name]  = Entry.new(name, klass, factory)
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
