RGen.simple_item(:register, :address_decoder) do
  rtl do
    generate_code_from_template(:module_item)

    def local_address_width
      source.register_block.local_address_width
    end

    def readable
      (source.readable? && 1) || 0
    end

    def writable
      (source.writable? && 1) || 0
    end

    def start_address
      hex(source.start_address, local_address_width)
    end

    def end_address
      hex(source.end_address, local_address_width)
    end
  end
end
