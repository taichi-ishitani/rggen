simple_item :register, :array do
  register_map do
    field :array?
    field :dimensions

    build do |cell|
      parse_dimension(cell.to_s)
    end

    validate do
      case
      when mismatch_with_own_byte_size?
        error "mismatches with own byte size(#{register.byte_size}):" \
              " #{dimensions}"
      end
    end

    def parse_dimension(value)
      case value
      when empty?
        @array      = false
        @dimensions = nil
      when /\A\[ *([1-9]\d*) *\]\z/
        @array      = true
        @dimensions = Regexp.last_match.captures.map(&:to_i)
      else
        error "invalid value for array dimension: #{value.inspect}"
      end
    end

    def empty?
      lambda { |v| v.empty? }
    end

    def mismatch_with_own_byte_size?
      return false unless array?
      register.byte_size != dimensions.first * configuration.byte_width
    end
  end
end