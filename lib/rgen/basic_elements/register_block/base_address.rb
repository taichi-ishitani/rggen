RGen.item(:register_block, :base_address) do
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
      when @end_address > max_address
        error "exceeds the maximum base address" \
              "(0x#{max_address.to_s(16)}): #{cell}"
      when unaligned_address?
        error "unaligned base address: #{cell}"
      when overlapped_address?
        error "overlapped base address: #{cell}"
      end
    end

    def parse_address(value)
      match = /\A(0x\h[\h_]*)[ \t]*-[ \t]*(0x\h[\h_]*)\z/i.match(value)
      if match
        @start_address  = match.captures[0].hex
        @end_address    = match.captures[1].hex
      else
        error "invalid value for base address: #{value.inspect}"
      end
    end

    def max_address
      2**configuration.address_width - 1
    end

    def unaligned_address?
      return true unless (@start_address + 0).multiple?(configuration.byte_width)
      return true unless (@end_address   + 1).multiple?(configuration.byte_width)
      false
    end

    def overlapped_address?
      own_range = @start_address..@end_address
      register_map.register_blocks.any? do |block|
        own_range.overlap?(block.start_address..block.end_address)
      end
    end
  end
end
