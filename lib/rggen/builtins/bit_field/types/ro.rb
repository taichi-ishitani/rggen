list_item :bit_field, :type, :ro do
  register_map do
    read_only
  end

  rtl do
    build do
      input :register_block, :value_in,
            name:       "i_#{bit_field.name}",
            width:      width,
            dimensions: dimensions
    end

    generate_code_from_template :register
  end

  ral do
    hdl_path { "u_#{bit_field.name}.i_value" }
  end
end
