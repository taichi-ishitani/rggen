RGen.item(:register_block, :name) do
  register_map do
    field :name

    build do |cell|
      @name = cell.to_s
      unless valid_name?(@name)
        error "invalid value for register block name: #{cell.inspect}"
      end
      unless unique_name?(@name)
        error "repeated register block name: #{@name}"
      end
    end

    def valid_name?(name)
      /\A[a-z_][a-z0-9_]*\z/i.match(name).not_nil?
    end

    def unique_name?(name)
      register_map.register_blocks.none? do |block|
        name == block.name
      end
    end
  end
end
