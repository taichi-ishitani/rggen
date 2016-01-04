simple_item(:register, :address_decoder) do
  rtl do
    generate_code_from_template(:module_item)

    delegate local_address_width: :register_block

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
      address_code(register.start_address)
    end

    def end_address
      if register.array?
        address = register.start_address + configuration.byte_width - 1
        address_code(address)
      else
        address_code(register.end_address)
      end
    end

    def address_code(address)
      shift = address_lsb
      base  = hex(address >> shift, local_address_width - shift)
      (register.array? && "#{base} + #{register.local_index}") || base
    end
  end
end
