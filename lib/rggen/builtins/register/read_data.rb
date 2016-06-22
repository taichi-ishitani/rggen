simple_item :register, :read_data do
  rtl do
    available? { register.internal? }

    define_helpers do
      def read_data_entry(args)
        @read_data_entry ||= Struct.new(:lsb, :msb, :value, :dummy)
        @read_data_entry.new.tap do |entry|
          entry.lsb   = args[:lsb]
          entry.msb   = args[:msb]
          entry.value = args[:value]
          entry.dummy = args[:dummy] || false
        end
      end
    end

    generate_code :module_item do |buffer|
      buffer  << assign(register_read_data, read_data) << nl
    end

    class_delegator :read_data_entry
    delegate [:data_width] => :configuration
    delegate [:loop_variables] => :register

    def register_read_data
      register_block.register_read_data[register.index]
    end

    def read_data
      if register.readable?
        concat(*read_data_expressions)
      else
        hex(0, configuration.data_width)
      end
    end

    def read_data_expressions
      read_data_entries.each_cons(2).with_object([]) do |entries, expressions|
        padding_bits  = entries[0].lsb - entries[1].msb - 1
        expressions << hex(0, padding_bits) if padding_bits > 0
        expressions << entries[1].value unless entries[1].dummy
      end
    end

    def read_data_entries
      [].tap do |entries|
        entries << read_data_entry(lsb: data_width, dummy: true)
        entries.concat(readable_field_entries)
        entries << read_data_entry(msb: -1, dummy: true)
      end
    end

    def readable_field_entries
      readable_fields.map do |field|
        read_data_entry(
          lsb: field.lsb, msb: field.msb, value: field.value[loop_variables]
        )
      end
    end

    def readable_fields
      register.bit_fields.select(&:readable?).sort_by(&:msb).reverse
    end
  end
end
