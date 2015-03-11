RGen.loader(:register_map, [:csv, :tsv]) do
  require 'csv'

  def load_file(file)
    map   = create_map(file)
    sheet = map['N/A']
    CSV.read(file, col_sep: separator(file)).each_with_index do |cells, row|
      cells.each_with_index do |cell, column|
        sheet[row, column]  = cell
      end
    end
    map
  end

  def separator(file)
    (File.extname(file) == ".csv") ? "," : "\t"
  end
end
