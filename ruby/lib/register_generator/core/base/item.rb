module RegisterGenerator::Base
  class Item
    def initialize(owner)
      @owner  = owner
      owner.append_item(self)
    end

    attr_reader :owner
  end
end
