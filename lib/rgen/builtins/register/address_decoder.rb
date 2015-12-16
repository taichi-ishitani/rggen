simple_item(:register, :address_decoder) do
  rtl do
    generate_code_from_template(:module_item)

    def local_address_width
      register_block.local_address_width
    end

    def address_lsb
      Math.clog2(configuration.byte_width)
    end

    def readable
      (register.readable? && 1) || 0
    end

    def writable
      (register.writable? && 1) || 0
    end

    def start_address
      shift = address_lsb
      hex(register.start_address >> shift, local_address_width - shift)
    end

    def end_address
      shift = address_lsb
      hex(register.end_address >> shift, local_address_width - shift)
    end
  end
end
