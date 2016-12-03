simple_item :register_block, :response_mux do
  rtl do
    build do
      logic :register_select   , width: total_registers
      logic :register_read_data,
            width:      configuration.data_width,
            dimensions: [total_registers]
      if external_registers?
        logic :external_register_select,
              width:  total_external_registers,
              vector: true
        logic :external_register_ready ,
              width:  total_external_registers,
              vector: true
        logic :external_register_status,
              width:      2,
              dimensions: [total_external_registers]
      end
    end

    generate_code_from_template :module_item

    def total_registers
      register_block.registers.sum(0, &:count)
    end

    def external_registers?
      register_block.registers.any? { |r| r.type?(:external) }
    end

    def total_external_registers
      register_block.registers.count  { |r| r.type?(:external) }
    end

    def actual_external_register_select
      (external_registers? && external_register_select) || bin(0, 1)
    end

    def actual_external_register_ready
      (external_registers? && external_register_ready) || bin(0, 1)
    end

    def actual_external_register_status
      (external_registers? && external_register_status)  || array(bin(0, 2))
    end
  end
end
