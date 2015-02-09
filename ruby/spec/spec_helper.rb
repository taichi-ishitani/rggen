require_relative '../lib/rgen'
require_relative  'matchers/raise_load_error'
require_relative  'matchers/raise_configuration_error'
require_relative  'matchers/raise_register_map_error'

def create_cell(value, options = {})
  file    = options[:file]   || "foo.csv"
  sheet   = options[:sheet]  || "foo"
  row     = options[:row]    || 0
  column  = options[:column] || 0
  c       = RGen::RegisterMap::GenericMap::Cell.new(file, sheet, row, column)
  c.value = value
  c
end

def create_cells(values, options = {})
  column  = options[:column] || 0
  Array(values).map.with_index do |value, index|
    new_options = options.clone
    new_options[:column]  = column + index
    create_cell(value, new_options)
  end
end
