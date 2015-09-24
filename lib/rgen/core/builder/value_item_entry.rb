module RGen::Builder
  class ValueItemEntry
    def initialize(base, factory, *contexts, &body)
      @item_class = Class.new(base)
      @factory  = factory
      @item_class.class_exec(*contexts, &body)  if block_given?
    end

    attr_reader :item_class
    attr_reader :factory

    def build_factory
      f = @factory.new(:value_item_factory)
      f.register(@item_class)
      f
    end
  end
end
