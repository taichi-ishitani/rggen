module Roo
  module TableFormatter
    def to_table(sheet = default_sheet, **options)
      from_row    = options[:from_row]    || first_row(sheet)
      to_row      = options[:to_row]      || last_row(sheet)
      from_column = options[:from_column] || first_column(sheet)
      to_column   = options[:to_column]   || last_column(sheet)
      from_row.upto(to_row).map do |row|
        from_column.upto(to_column).map { |column| cell(row, column, sheet) }
      end
    end
  end

  class Base
    include TableFormatter
  end
end
