RGen.loader(:register_map, [:csv, :tsv]) do
  require 'csv'

  def load_file(file)
    map         = create_map(file)
    map['N/A']  = CSV.read(file, col_sep: separator(file))
    map
  end

  def separator(file)
    (File.extname(file) == ".csv") ? "," : "\t"
  end
end
