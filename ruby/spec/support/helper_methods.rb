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

def create_sheet(values, options = {})
  file        = options[:file]  || "foo.csv"
  sheet_name  = options[:sheet] || "foo"
  sheet       = RGen::RegisterMap::GenericMap::Sheet.new(file, sheet_name)
  values.each_with_index do |row, row_index|
    row.each_with_index do |value, column_index|
      sheet[row_index, column_index]  = value
    end
  end
  sheet
end
