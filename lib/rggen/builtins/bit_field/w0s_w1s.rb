list_item :bit_field, :type, [:w0s, :w1s] do
  register_map do
    read_write
    need_initial_value
  end

  rtl do
    delegate [:name, :type] => :bit_field

    build do
      output :value_out,
             name:      "o_#{name}",
             width:      width,
             dimensions: dimensions
       input :clear,
             name:       "i_#{name}_clear",
             width:      width,
             dimensions: dimensions
    end

    generate_code :module_item do |code|
      code << assign(value_out[loop_variables], value[loop_variables]) << nl
      code << process_template
    end

    def initial_value
      hex(bit_field.initial_value, width)
    end

    def set_value
      { w0s: 0, w1s: 1 }[type]
    end
  end
end
