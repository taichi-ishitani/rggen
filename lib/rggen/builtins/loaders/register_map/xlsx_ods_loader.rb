loader :register_map, [:xlsx, :ods] do
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
      sheet.first_row && (sheets[sheet_name] = process_sheet(sheet))
    end
    sheets
  end

  def process_sheet(sheet)
    sheet.to_table(from_column: 1)
  end
end
