class RGen::RegisterMap::GenericMap
  class Cell
    Position  = Struct.new(:file, :sheet, :row, :column)

    def initialize(file, sheet, row, column)
      @position = Position.new(file, sheet, row, column)
    end

    attr_accessor :value
    attr_reader   :position

    def empty?
      value.to_s.empty?
    end
  end
end
