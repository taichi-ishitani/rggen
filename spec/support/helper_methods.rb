def get_component_class(store_name, index)
  component_class = nil
  RGen.builder.instance_eval do
    @stores[store_name].instance_eval do
      component_class = @entries[index].component_class
    end
  end
  component_class
end

def get_component_factory(store_name, index)
  component_factory = nil
  RGen.builder.instance_eval do
    @stores[store_name].instance_eval do
      component_factory = @entries[index].component_factory
    end
  end
  component_factory
end

def get_item_base(store_name, index)
  item_base = nil
  RGen.builder.instance_eval do
    @stores[store_name].instance_eval do
      item_base = @entries[index].item_base
    end
  end
  item_base
end

def get_item_factory(store_name, index)
  item_factory  = nil
  RGen.builder.instance_eval do
    @stores[store_name].instance_eval do
      item_factory  = @entries[index].item_factory
    end
  end
  item_factory
end

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

def create_map(values, file_name = "foo.csv")
  map = RGen::RegisterMap::GenericMap.new(file_name)
  values.each do |sheet, table|
    sheet = map[sheet]
    table.each_with_index do |row, row_index|
      row.each_with_index do |value, column_index|
        sheet[row_index, column_index]  = value
      end
    end
  end
  map
end
