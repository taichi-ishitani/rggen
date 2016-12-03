simple_item :register, :address_decoder do
  rtl do
    build do
      next unless type?(:indirect)
      logic :indirect_index,
            name:       "#{register.name}_indirect_index",
            width:      indirect_index_width,
            dimensions: register.dimensions
    end

    generate_code :module_item do |buffer|
      buffer << indirect_index_assignment << nl if type?(:indirect)
      buffer << process_template
    end

    delegate [:local_address_width] => :register_block
    delegate [:array?, :type?, :multiple?] => :register
    delegate [:indexes, :loop_variables] => :register

    def address_lsb
      Math.clog2(configuration.byte_width)
    end

    def start_address
      address_code(register.start_address)
    end

    def end_address
      if array?
        address = register.start_address + configuration.byte_width - 1
        address_code(address)
      else
        address_code(register.end_address)
      end
    end

    def address_code(address)
      shift = address_lsb
      base  = hex(address >> shift, local_address_width - shift)
      (array? && multiple? && "#{base} + #{register.local_index}") || base
    end

    def indirect_index_assignment
      assign(
        indirect_index[register.loop_variables],
        concat(indirect_index_fields.map(&:value))
      )
    end

    def indirect_register
      (type?(:indirect) && 1) || 0
    end

    def indirect_index_width
      return 1 unless type?(:indirect)
      indirect_index_fields.sum(0, &:width)
    end

    def indirect_index_value
      return hex(0, 1) unless type?(:indirect)
      concat(indirect_index_values)
    end

    def indirect_index_fields
      @indirect_index_fields ||= indexes.map do |index|
        register_block.bit_fields.find_by(name: index.name)
      end
    end

    def indirect_index_values
      variables = loop_variables
      indexes.map.with_index do |index, i|
        if index.value
          hex(index.value, indirect_index_fields[i].width)
        else
          loop_variable = variables.shift
          loop_variable[indirect_index_fields[i].width - 1, 0]
        end
      end
    end
  end
end
