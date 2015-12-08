loader(:register_map, [:xlsx, :ods]) do
  require 'roo'

  def load_file(file)
    create_map(file) do |map|
      load_spreadsheet(file).each do |sheet_name, sheet|
        map[sheet_name] = sheet
      end
    end
  end

  def load_spreadsheet(file)
    sheets  = {}
    Roo::Spreadsheet.open(file).each_with_pagename do |sheet_name, sheet|
      next unless sheet.first_row
      sheets[sheet_name]  = 1.upto(sheet.last_row).map do |row|
        1.upto(sheet.last_column).map do |column|
          sheet.cell(row, column)
        end
      end
    end
    sheets
  end
end
