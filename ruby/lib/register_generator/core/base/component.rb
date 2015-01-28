module RegisterGenerator::Base
  class Component
    def initialize(parent = nil)
      @parent   = parent
      @items    = []
      @children = []
    end

    attr_reader :parent
    attr_reader :items
    attr_reader :children

    def append_item(item)
      items << item
    end

    def append_child(child)
      children  << child
    end
  end
end
