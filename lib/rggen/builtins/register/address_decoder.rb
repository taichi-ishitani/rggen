simple_item :register, :address_decoder do
  rtl do
    build do
      next unless register.shadow?
      logic :shadow_index,
            name:       "#{register.name}_shadow_index",
            width:      shadow_index_width,
            dimensions: register.dimensions
    end

    generate_code :module_item do |buffer|
      buffer << shadow_index_assignment << nl if shadow?
      buffer << process_template
    end

    delegate [:local_address_width] => :register_block
    delegate [:array?, :shadow?, :multiple?] => :register
    delegate [:shadow_indexes, :loop_variables] => :register

    def readable
      ((register.readable? || register.reserved?) && 1) || 0
    end

    def writable
      ((register.writable? || register.reserved?) && 1) || 0
    end

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

    def shadow_index_assignment
      assign(
        shadow_index[register.loop_variables],
        concat(*shadow_index_fields.map(&:value))
      )
    end

    def use_shadow_index
      (shadow? && 1) || 0
    end

    def shadow_index_width
      return 1 unless shadow?
      shadow_index_fields.sum(0, &:width)
    end

    def shadow_index_value
      return hex(0, 1) unless shadow?
      concat(*shadow_index_values)
    end

    def shadow_index_fields
      @shadow_index_fields ||= shadow_indexes.map do |index|
        register_block.bit_fields.find do |bit_field|
          bit_field.name == index.name
        end
      end
    end

    def shadow_index_values
      variables = loop_variables
      shadow_indexes.map.with_index do |index, i|
        if index.value
          hex(index.value, shadow_index_fields[i].width)
        else
          loop_variable = variables.shift
          loop_variable[shadow_index_fields[i].width - 1, 0]
        end
      end
    end
  end
end
