module RgGen
  module RegisterMap
    class GenericMap
      class Cell
        Position  = Struct.new(:file, :sheet, :row, :column)

        def initialize(file, sheet, row, column)
          @position = Position.new(file, sheet, row, column)
        end

        attr_accessor :value
        attr_reader   :position

        def empty?
          value.to_s.empty?
        end
      end

      class Sheet
        def initialize(file, name)
          @file = file
          @name = name
          @rows = []
        end

        attr_reader :name
        attr_reader :rows

        def [](row, column)
          rows[row]         ||= []
          rows[row][column] ||= Cell.new(@file, name, row, column)
        end

        def []=(row, column, value)
          self[row, column].value = value
        end
      end

      def initialize(file)
        @file   = file
        @sheets = {}
      end

      attr_reader :file

      def [](sheet_name_or_index)
        case sheet_name_or_index
        when String
          @sheets[sheet_name_or_index]  ||= Sheet.new(file, sheet_name_or_index)
        when Integer
          sheets[sheet_name_or_index]
        end
      end

      def []=(sheet_name, table)
        @sheets[sheet_name] = Sheet.new(file, sheet_name)
        table.each_with_index do |values, row|
          values.each_with_index do |value, column|
            @sheets[sheet_name][row, column]  = value
          end
        end
      end

      def sheets
        @sheets.values
      end
    end
  end
end
