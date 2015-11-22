RGen.simple_item(:register_block, :response_mux) do
  rtl do
    build do
      logic :register_select   , width: total_registers
      logic :register_read_data, width: data_width, dimension: total_registers
    end

    generate_code(:module_item) do |buffer|
      buffer  << process_template
    end

    def data_width
      configuration.data_width
    end

    def total_registers
      @total_registers  ||= source.registers.size
    end
  end
end
