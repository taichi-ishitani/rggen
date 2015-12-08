simple_item(:bit_field, :name) do
  register_map do
    field :name

    build do |cell|
      @name = cell.to_s
      if invalid_value?
        error "invalid value for bit field name: #{cell.inspect}"
      elsif repeated_name?
        error "repeated bit field name: #{@name}"
      end
    end

    def invalid_value?
      /\A[a-z_][a-z0-9_]*\z/i.match(@name).nil?
    end

    def repeated_name?
      register_block.bit_fields.any? do |bit_field|
        @name == bit_field.name
      end
    end
  end
end
