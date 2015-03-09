RGen.item(:register_block, :name) do
  register_map do
    VALID_PATTERN = /\A[a-z_][a-z0-9_]*\z/i

    field :name

    build do |cell|
      @name = cell.to_s
      unless @name =~ VALID_PATTERN
        error "invalid value for register block name: #{cell.inspect}"
      end
      if register_map.register_blocks.any? {|block| @name == block.name}
        error "repeated register block name: #{@name}"
      end
    end
  end
end
