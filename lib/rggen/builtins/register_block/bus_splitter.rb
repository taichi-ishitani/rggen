simple_item :register_block, :bus_splitter do
  rtl do
    delegate [:local_address_width] => :register_block
    delegate [:data_width] => :configuration

    build do
      interface :register_if,
                type:       :rggen_register_if,
                parameters: [local_address_width, data_width],
                dimensions: [total_registers]
    end

    generate_code_from_template :module_item

    def total_registers
      register_block.registers.sum(0, &:count)
    end
  end
end
