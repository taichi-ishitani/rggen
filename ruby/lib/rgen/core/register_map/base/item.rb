class RGen::RegisterMap::Base::Item < RGen::InputBase::Item
  attr_reader :configuration

  def build(configuration, cell)
    @configuration  = configuration
    @position       = cell.position
    super(cell.value)
  end

  def error(message)
    raise RGen::RegisterMapError.new(message, @position)
  end
  private :error
end
