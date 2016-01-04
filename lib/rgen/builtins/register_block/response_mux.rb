simple_item(:register_block, :response_mux) do
  rtl do
    build do
      logic :register_select   , width: total_registers
      logic :register_read_data, width: data_width, dimensions: [total_registers]
    end

    generate_code_from_template(:module_item)

    delegate data_width: :configuration

    def total_registers
      register_block.registers.map(&:count).sum(0)
    end
  end
end
