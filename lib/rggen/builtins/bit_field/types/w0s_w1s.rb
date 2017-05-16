list_item :bit_field, :type, [:w0s, :w1s] do
  register_map do
    read_write
    need_initial_value
  end

  rtl do
    delegate [:name, :type] => :bit_field

    build do
      output :register_block, :value_out,
             name:      "o_#{name}",
             width:      width,
             dimensions: dimensions
       input :register_block, :clear,
             name:       "i_#{name}_clear",
             width:      width,
             dimensions: dimensions
    end

    generate_code_from_template :register

    def initial_value
      hex(bit_field.initial_value, width)
    end

    def set_value
      { w0s: 0, w1s: 1 }[type]
    end
  end
end
