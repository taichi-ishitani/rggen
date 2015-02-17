module RGen::Builder
  class Registry
    Entry = Struct.new(:name, :item_class, :factory) do
      def create_factory
        f = factory.new
        f.register(name, item_class)
        f
      end
    end

    def initialize
      @entries  = {}
    end

    attr_reader :entries

    def base(base_class = nil)
      @base_class ||= base_class
    end

    def factory(item_factory = nil)
      @factory  ||= item_factory
    end

    def register_item(item_name, entry = nil, &body)
      if block_given?
        entries[item_name]  = create_entry(item_name, body)
      else
        entries[item_name]  = entry
      end
    end

    def enable(*enabled_items)
      @enabled_items  = enabled_items
    end

    def enabled_factories
      @enabled_items.each_with_object({}) do |name, factories|
        factories[name] = entries[name].create_factory
      end
    end

    private

    def create_entry(item_name, body)
      klass = Class.new(@base_class, &body)
      Entry.new(item_name, klass, @factory)
    end
  end
end
