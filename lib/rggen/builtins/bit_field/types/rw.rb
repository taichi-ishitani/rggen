list_item :bit_field, :type, :rw do
  register_map do
    read_write
    need_initial_value
  end

  rtl do
    build do
      output :value_out, name: port_name, width: width, dimensions: dimensions
    end

    generate_code :module_item do |buffer|
      buffer << assign(value_out[loop_variables], value[loop_variables]) << nl
      buffer << process_template
    end

    def port_name
      "o_#{bit_field.name}"
    end

    def initial_value
      hex(bit_field.initial_value, bit_field.width)
    end
  end
end
