simple_item :register, :offset_address do
  register_map do
    field :start_address
    field :end_address
    field :byte_size do
      end_address - start_address + 1
    end
    field :single? do
      byte_size == configuration.byte_width
    end
    field :multiple? do
      byte_size > configuration.byte_width
    end

    OFFSET_ADDRESS_REGEXP = (
      /\A#{blank}/ +
      /(#{number})(?:#{wrap_blank(/-/)}(#{number}))?/ +
      /#{blank}\z/
    )

    build do |cell|
      @start_address, @end_address  = parse_address(cell.to_s)
      case
      when @start_address >= @end_address
        error "start address is equal to or greater than end address: #{cell}"
      when unaligned_address?
        error 'not aligned with data width' \
              "(#{configuration.data_width}): #{cell}"
      when @end_address > max_address
        error 'exceeds the maximum offset address' \
              "(0x#{max_address.to_s(16)}): #{cell}"
      when overlapped_address?
        error "overlapped offset address: #{cell}"
      end
    end

    def parse_address(value)
      case value
      when OFFSET_ADDRESS_REGEXP
        captures  = Regexp.last_match.captures.compact.map(&method(:Integer))
        if captures.size == 2
          captures
        else
          [captures[0], captures[0] + configuration.byte_width - 1]
        end
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
