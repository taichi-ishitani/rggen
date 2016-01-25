simple_item :register, :read_data do
  rtl do
    generate_code :module_item do |buffer|
      buffer  << assign(register_read_data, read_data) << nl
    end

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
      last_lsb    = configuration.data_width
      expressions = []
      readable_fields.each do |field|
        padding_bits  = last_lsb - field.msb - 1
        last_lsb      = field.lsb
        expressions << hex(0, padding_bits) if padding_bits > 0
        expressions << field.value[register.loop_variables]
      end
      expressions << hex(0, last_lsb) if last_lsb > 0
      expressions
    end

    def readable_fields
      register.bit_fields.select(&:readable?).sort_by(&:msb).reverse
    end
  end
end
