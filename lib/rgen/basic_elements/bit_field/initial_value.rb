RGen.value_item(:bit_field, :initial_value) do
  register_map do
    field :initial_value

    build do |cell|
      begin
        @initial_value  = Integer(cell)
      rescue
        error "invalid value for initial value: #{cell.inspect}"
      end
    end

    validate do
      unless valid_range.include?(@initial_value)
        error "out of valid initial value range(#{valid_range}):" \
              " #{@initial_value}"
      end
    end

    def valid_range
      min_value = -1 * (2**bit_field.width) / 2
      max_value = 2**bit_field.width - 1
      (min_value..max_value)
    end
  end
end
