list_item :bit_field, :type, :rw do
  register_map do
    read_write
    need_initial_value
  end

  rtl do
    build do
      output :register_block, :value_out,
             name: "o_#{bit_field.name}",
             width: width,
             dimensions: dimensions
    end

    generate_code_from_template :bit_field

    def initial_value
      hex(bit_field.initial_value, bit_field.width)
    end
  end
end
