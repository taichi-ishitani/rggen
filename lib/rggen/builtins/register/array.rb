simple_item :register, :array do
  register_map do
    field :array?
    field :dimensions
    field :count

    input_pattern %r{\[(#{number}(?:,#{number})*)\]},
                  match_automatically: false

    build do |cell|
      @dimensions = parse_array_dimensions(cell)
      @array      = @dimensions.not_nil?
      @count      = (@dimensions && @dimensions.inject(&:*)) || 1
      if @dimensions && @dimensions.any?(&:zero?)
        error "0 is not allowed for array dimension: #{cell.inspect}"
      end
    end

    def parse_array_dimensions(cell)
      case
      when cell.nil? || cell.empty?
        nil
      when pattern_match(cell)
        captures.first.split(',').map(&method(:Integer))
      else
        error "invalid value for array dimension: #{cell.inspect}"
      end
    end
  end
end
