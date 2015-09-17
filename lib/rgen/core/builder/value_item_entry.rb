module RGen::Builder
  class ValueItemEntry
    def initialize(base, body, factory)
      @item_class = Class.new(base, &body)
      @factory    = factory
    end

    attr_reader :item_class
    attr_reader :factory

    def build_factory
      f = @factory.new
      f.register(@item_class)
      f
    end
  end
end
