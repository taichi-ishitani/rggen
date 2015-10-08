RGen.simple_item(:register_block, :name) do
  register_map do
    field :name

    build do |cell|
      @name = cell.to_s
      if invalid_value?
        error "invalid value for register block name: #{cell.inspect}"
      elsif repeated_name?
        error "repeated register block name: #{@name}"
      end
    end

    def invalid_value?
      /\A[a-z_][a-z0-9_]*\z/i.match(@name).nil?
    end

    def repeated_name?
      register_map.register_blocks.any? do |block|
        @name == block.name
      end
    end
  end
end
