loader :register_map, :xls do
  require 'spreadsheet'

  def load_file(file)
    create_map(file) do |map|
      load_spreadsheet(file).each do |worksheet|
        map[worksheet.name] = worksheet.rows
      end
    end
  end

  def load_spreadsheet(file)
    Spreadsheet.open(file, 'rb') do |book|
      book.worksheets.select do |worksheet|
        worksheet.row_count > 0
      end
    end
  end
end
