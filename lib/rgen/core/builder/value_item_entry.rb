module RGen::Builder
  class ValueItemEntry
    def initialize(factory)
      @factory  = factory
    end

    attr_reader :factory

    def item_class(base = nil, &body)
      @item_class ||= Class.new(base, &body) if base && block_given?
      @item_class
    end

    def build_factory
      f = @factory.new
      f.register(@item_class)
      f
    end
  end
end
