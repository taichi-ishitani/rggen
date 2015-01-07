module RegisterGenerator::Core::Base
  class BaseObject
    def initialize(parent = nil)
      @parent   = parent
      @children = []
      @parent.children << self if parent
    end

    attr_reader :parent
    attr_reader :children
  end
end
