RGen.item(:register, :name) do
  register_map do
    field :name

    build do |cell|
      @name = cell.to_s
      if invalid_value?(@name)
        error "invalid value for register name: #{cell.inspect}"
      elsif repeated_name?(@name)
        error "repeated register name: #{@name}"
      end
    end

    def invalid_value?(name)
      /\A[a-z_][a-z0-9_]*\z/i.match(name).nil?
    end

    def repeated_name?(name)
      register_block.registers.any? do |register|
        name == register.name
      end
    end
  end
end
