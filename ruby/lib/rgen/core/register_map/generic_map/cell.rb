class RGen::RegisterMap::GenericMap::Cell
  Position  = Struct.new(:file, :sheet, :row, :column)

  def initialize(file, sheet, row, column)
    @position = Position.new(file, sheet, row, column)
  end

  attr_accessor :value
  attr_reader   :position

  def empty?
    value.to_s.strip.empty?
  end
end
