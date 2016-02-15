simple_item :bit_field, :initial_value do
  register_map do
    field :initial_value
    field :initial_value? do
      @initial_value.not_nil?
    end

    build do |cell|
      @initial_value  = parse_initial_value(cell)
    end

    validate do
      if initial_value? && valid_range.exclude?(@initial_value)
        error "out of valid initial value range(#{valid_range}):" \
              " #{@initial_value}"
      end
    end

    def parse_initial_value(cell)
      return if empty?(cell)
      Integer(cell)
    rescue
      error "invalid value for initial value: #{cell.inspect}"
    end

    def empty?(cell)
      cell.to_s.strip.empty?
    end

    def valid_range
      min_value = -1 * (2**bit_field.width) / 2
      max_value = 2**bit_field.width - 1
      (min_value..max_value)
    end
  end
end
