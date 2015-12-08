simple_item(:register_block, :base_address) do
  register_map do
    field :start_address
    field :end_address
    field :byte_size
    field :local_address_width

    build do |cell|
      parse_address(cell.to_s)
      case
      when @start_address >= @end_address
        error "start address is equal to or greater than end address: #{cell}"
      when not_aligned_with_data_width?
        error "not aligned with data width" \
              "(#{configuration.data_width}): #{cell}"
      when not_aligned_with_local_address_width?
        error "not aligned with local address width" \
              "(#{@local_address_width}): #{cell}"
      when @end_address > max_address
        error "exceeds the maximum base address" \
              "(0x#{max_address.to_s(16)}): #{cell}"
      when overlapped_address?
        error "overlapped base address: #{cell}"
      end
    end

    def parse_address(value)
      match = /\A(0x\h[\h_]*) *- *(0x\h[\h_]*)\z/i.match(value)
      if match
        @start_address        = match.captures[0].hex
        @end_address          = match.captures[1].hex
        @byte_size            = @end_address - @start_address + 1
        @local_address_width  = Math.clog2(@byte_size) if @byte_size > 0
      else
        error "invalid value for base address: #{value.inspect}"
      end
    end

    def not_aligned_with_data_width?
      byte_width  = configuration.byte_width
      return true unless (@start_address + 0).multiple?(byte_width)
      return true unless (@end_address   + 1).multiple?(byte_width)
      false
    end

    def not_aligned_with_local_address_width?
      window_size = 2**@local_address_width
      return true unless @start_address.multiple?(window_size)
      false
    end

    def max_address
      2**configuration.address_width - 1
    end

    def overlapped_address?
      own_range = @start_address..@end_address
      register_map.register_blocks.any? do |block|
        own_range.overlap?(block.start_address..block.end_address)
      end
    end
  end
end
