simple_item :register, :name do
  register_map do
    field :name

    input_pattern %r{\A(#{variable_name})\z}, ignore_blank: true

    build do |cell|
      @name = parse_name(cell)
      error "repeated register name: #{@name}" if repeated_name?
    end

    def parse_name(cell)
      if match_data
        captures.first
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
