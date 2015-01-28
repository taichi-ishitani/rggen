module RegisterGenerator::Base
  class Item
    def initialize(owner)
      @owner  = owner
    end

    attr_reader :owner
  end
end
