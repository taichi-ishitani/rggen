class RGen::RegisterMap::GenericMap
  def initialize(file)
    @file   = file
    @sheets = {}
  end

  attr_reader :file

  def [](sheet_name_or_index)
    case sheet_name_or_index
    when String
      @sheets[sheet_name_or_index]  ||= Sheet.new(self, sheet_name_or_index)
    when Integer
      sheets[sheet_name_or_index]
    end
  end

  def sheets
    @sheets.values
  end
end

require_relative  'generic_map/sheet'
require_relative  'generic_map/cell'
