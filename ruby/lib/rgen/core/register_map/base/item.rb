module RGen::RegisterMap::Base
  class Item < RGen::InputBase::Item
    attr_reader :configuration

    def build(configuration, cell)
      @configuration  = configuration
      @position       = cell.position
      super(cell.value)
    end

    private

    def error(message)
      fail RGen::RegisterMapError.new(message, @position)
    end
  end
end
