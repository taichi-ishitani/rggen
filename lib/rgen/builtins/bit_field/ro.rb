list_item(:bit_field, :type, :ro) do
  register_map do
    read_only
  end

  rtl do
    build do
      input :value_in, name: port_name, width: width, dimensions: dimensions
    end

    generate_code(:module_item) do |buffer|
      buffer << assign(value[loop_variables], value_in[loop_variables]) << nl
    end

    def port_name
      "i_#{bit_field.name}"
    end

    delegate local_index: :register
  end
end
