RGen.list_item(:bit_field, :type, :rw) do
  register_map do
    read_write
  end

  rtl do
    build do
      output :value_out, name: "o_#{bit_field.name}", width: bit_field.width
    end

    generate_code(:module_item) do |buffer|
      buffer << assign(value_out, value) << "\n"
      buffer << process_template
    end

    def initial_value
      hex(bit_field.initial_value, bit_field.width)
    end
  end
end
