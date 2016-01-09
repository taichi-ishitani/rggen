simple_item :bit_field, :bit_assignment do
  register_map do
    field :msb
    field :lsb
    field :width do
      msb - lsb + 1
    end

    input_pattern %r{\[(#{number})(?::(#{number}))?\]}

    build do |cell|
      parse_bit_assignment(cell)
      case
      when @lsb > @msb
        error "lsb is larger than msb: #{cell}"
      when @msb >= configuration.data_width
        error "exceeds the data width(#{configuration.data_width}): #{cell}"
      when overlapped_bit_assignment?
        error "overlapped bit assignment: #{cell}"
      end
    end

    def parse_bit_assignment(cell)
      if pattern_matched?
        @msb, @lsb  = captures.compact.map(&method(:Integer))
        @lsb ||= @msb
      else
        error "invalid value for bit assignment: #{cell.inspect}"
      end
    end

    def overlapped_bit_assignment?
      own_range = @lsb..@msb
      register.bit_fields.any? do |bit_field|
        own_range.overlap?(bit_field.lsb..bit_field.msb)
      end
    end
  end
end
