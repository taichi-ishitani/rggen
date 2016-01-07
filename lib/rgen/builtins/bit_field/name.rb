simple_item :bit_field, :name do
  register_map do
    field :name

    BIT_FIELD_AME_REGEXP  = /\A#{wrap_blank(/(#{variable_name})/)}\z/

    build do |cell|
      @name = parse_name(cell)
      error "repeated bit field name: #{@name}" if repeated_name?
    end

    def parse_name(cell)
      case cell
      when BIT_FIELD_AME_REGEXP
        Regexp.last_match.captures.first
      else
        error "invalid value for bit field name: #{cell.inspect}"
      end
    end

    def repeated_name?
      register_block.bit_fields.any? do |bit_field|
        @name == bit_field.name
      end
    end
  end
end
