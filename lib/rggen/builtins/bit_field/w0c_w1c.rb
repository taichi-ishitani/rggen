list_item :bit_field, :type, [:w0c, :w1c] do
  register_map do
    read_write
  end

  rtl do
    delegate [:name, :type] => :bit_field

    build do
      input :set, name: "i_#{name}_set", width: width, dimensions: dimensions
    end

    generate_code_from_template :module_item

    def initial_value
      (bit_field.initial_value? && bit_field.initial_value) || 0
    end

    def clear_value
      ((type == :w0c) && 0) || 1
    end
  end
end
