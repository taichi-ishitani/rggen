require_relative '../lib/rgen'
require_relative  'matchers/raise_load_error'
require_relative  'matchers/raise_configuration_error'
require_relative  'matchers/raise_register_map_error'

def create_cells(values, options = {})
  file    = options[:file]   || "foo.csv"
  sheet   = options[:sheet]  || "foo"
  row     = options[:row]    || 0
  column  = options[:column] || 0
  if Array == values
    values.map.with_index do |value, index|
      c       = RGen::RegisterMap::GenericMap::Cell.new(file, sheet, row, column + index)
      c.value = value
      c
    end
  else
    c       = RGen::RegisterMap::GenericMap::Cell.new(file, sheet, row, column)
    c.value = values
    c
  end
end
