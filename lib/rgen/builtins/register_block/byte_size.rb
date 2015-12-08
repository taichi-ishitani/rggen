simple_item(:register_block, :byte_size) do
  register_map do
    field :byte_size
    field :local_address_width

    build do |cell|
      begin
        @byte_size  = Integer(cell)
      rescue
        error "invalid value for byte size: #{cell.inspect}"
      end

      case
      when @byte_size.not.positive?
        error "zero or negative value is not allowed for byte size: #{cell}"
      when @byte_size.not.multiple?(configuration.byte_width)
        error "not aligned with data width" \
              "(#{configuration.data_width}): #{cell}"
      when total_byte_size > upper_bound
        error "exceeds upper bound of total byte size" \
              "(#{upper_bound}): #{total_byte_size}"
      end

      @local_address_width  = Math.clog2(@byte_size)
    end

    def upper_bound
      2**configuration.address_width
    end

    def total_byte_size
      register_map.register_blocks.inject(@byte_size) do |total, block|
        total + block.byte_size
      end
    end
  end
end
