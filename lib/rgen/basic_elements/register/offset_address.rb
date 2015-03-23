RGen.item(:register, :offset_address) do
  register_map do
    field :start_address
    field :end_address
    field :byte_size do
      end_address - start_address + 1
    end

    build do |cell|
      parse_address(cell.to_s)
      case
      when @start_address >= @end_address
        error "start address is equal to or greater than end address: #{cell}"
      when unaligned_address?
        error "not aligned with data width" \
              "(#{configuration.data_width}): #{cell}"
      when @end_address > max_address
        error "exceeds the maximum offset address" \
              "(0x#{max_address.to_s(16)}): #{cell}"
      when overlapped_address?
        error "overlapped offset address: #{cell}"
      end
    end

    def parse_address(value)
      case value
      when /\A(0x\h[\h_]*)\z/i
        @start_address  = Regexp.last_match[1].hex
        @end_address    = @start_address + configuration.byte_width - 1
      when /\A(0x\h[\h_]*) *- *(0x\h[\h_]*)\z/i
        @start_address  = Regexp.last_match[1].hex
        @end_address    = Regexp.last_match[2].hex
      else
        error "invalid value for offset address: #{value.inspect}"
      end
    end

    def unaligned_address?
      byte_width  = configuration.byte_width
      return true unless (@start_address + 0).multiple?(byte_width)
      return true unless (@end_address   + 1).multiple?(byte_width)
      false
    end

    def max_address
      register_block.byte_size - 1
    end

    def overlapped_address?
      own_range = @start_address..@end_address
      register_block.registers.any? do |register|
        own_range.overlap?(register.start_address..register.end_address)
      end
    end
  end
end
