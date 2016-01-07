simple_item :register_block, :name do
  register_map do
    field :name

    REGISTER_BLOCK_NAME_REGEXP  = /\A#{wrap_blank(/(#{variable_name})/)}\z/

    build do |cell|
      @name = parse_name(cell)
      error "repeated register block name: #{@name}" if repeated_name?
    end

    def parse_name(cell)
      case cell
      when REGISTER_BLOCK_NAME_REGEXP
        Regexp.last_match.captures.first
      else
        error "invalid value for register block name: #{cell.inspect}"
      end
    end

    def repeated_name?
      register_map.register_blocks.any? do |block|
        @name == block.name
      end
    end
  end
end
