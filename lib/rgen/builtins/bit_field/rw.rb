list_item(:bit_field, :type, :rw) do
  register_map do
    read_write
  end

  rtl do
    build do
      output :value_out, name: port_name, width: width, dimensions: dimensions
    end

    generate_code(:module_item) do |buffer|
      buffer << assign(value_out[local_index], value[local_index]) << nl
      buffer << process_template
    end

    def port_name
      "o_#{bit_field.name}"
    end

    def initial_value
      hex(bit_field.initial_value, bit_field.width)
    end

    delegate local_index: :register
  end
end
