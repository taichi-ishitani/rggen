RGen.simple_item(:register, :read_data) do
  rtl do
    generate_code(:module_item) do |buffer|
      buffer  << assign(register_read_data, read_data) << "\n"
    end

    def register_read_data
      register_block.register_read_data[register_index]
    end

    def read_data
      return hex(0, configuration.data_width) unless register.readable?
    end

    def readable_fields
      bit_fields.select
    end
  end
end
