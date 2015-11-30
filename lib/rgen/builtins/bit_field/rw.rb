RGen.list_item(:bit_field, :type, :rw) do
  register_map do
    read_write
  end

  rtl do
    build do
      output :value_out, name: "o_#{source.name}", width: source.width
    end

    generate_code(:module_item) do |buffer|
      buffer << assign(value_out, value) << "\n"
      buffer << process_template
    end

    def initial_value
      hex(source.initial_value, source.width)
    end

    def msb
      source.msb
    end

    def lsb
      source.lsb
    end
  end
end
