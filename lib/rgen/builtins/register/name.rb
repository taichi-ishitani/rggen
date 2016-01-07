simple_item :register, :name do
  register_map do
    field :name

    REGISTER_NAME_REGEXP  = /\A#{wrap_blank(/(#{variable_name})/)}\z/

    build do |cell|
      @name = parse_name(cell)
      error "repeated register name: #{@name}" if repeated_name?
    end

    def parse_name(cell)
      case cell
      when REGISTER_NAME_REGEXP
        Regexp.last_match.captures.first
      else
        error "invalid value for register name: #{cell.inspect}"
      end
    end

    def repeated_name?
      register_block.registers.any? do |register|
        @name == register.name
      end
    end
  end
end
