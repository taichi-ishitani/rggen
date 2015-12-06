RGen.simple_item(:register, :address_decoder) do
  rtl do
    generate_code_from_template(:module_item)

    def local_address_width
      register_block.local_address_width
    end

    def readable
      (register.readable? && 1) || 0
    end

    def writable
      (register.writable? && 1) || 0
    end

    def start_address
      hex(register.start_address, local_address_width)
    end

    def end_address
      hex(register.end_address, local_address_width)
    end
  end
end
