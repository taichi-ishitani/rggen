RGen.simple_item(:register, :address_decoder) do
  rtl do
    generate_code_from_template(:module_item)

    def address_width
      @address_width  ||= Math.log2(source.register_block.byte_size).ceil
    end

    def readable
      (source.readable? && 1) || 0
    end

    def writable
      (source.writable? && 1) || 0
    end

    def start_address
      hex(source.start_address, address_width)
    end

    def end_address
      hex(source.end_address, address_width)
    end

    def index
      register_block.registers.find_index do |r|
        r.equal?(register)
      end
    end
  end
end
