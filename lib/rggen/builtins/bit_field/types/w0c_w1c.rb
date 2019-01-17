list_item :bit_field, :type, [:w0c, :w1c] do
  register_map do
    read_write
    need_initial_value
    use_reference width: same_width
  end

  rtl do
    build do
      input :register_block, :set,
            name: "i_#{name}_set",
            width: width,
            dimensions: dimensions
    end

    generate_code_from_template :bit_field

    def initial_value
      hex(bit_field.initial_value, width)
    end

    def clear_value
      { w0c: 0, w1c: 1 }[type]
    end
  end
end
