module RGen::Base
  class Component
    def initialize(parent = nil)
      @parent   = parent
      @items    = []
      @children = []
    end

    attr_reader :parent
    attr_reader :items
    attr_reader :children

    def add_item(item)
      items << item
    end

    def add_child(child)
      children  << child
    end
  end
end
