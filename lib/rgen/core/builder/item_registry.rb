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
      @entries[name]  = create_entry(name, body)
    end

    def enable(*item_names)
      @enabled_items.concat(item_names)
    end

    def build_factories
      @enabled_items.uniq.each_with_object({}) do |name, factories|
        factories[name] = @entries[name].build_factory if @entries.key?(name)
      end
    end

    private

    def create_entry(name, body)
      klass = Class.new(base, &body)
      Entry.new(name, klass, factory)
    end
  end
end
