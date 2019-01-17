list_item :bit_field, :type, :ro do
  register_map do
    read_only
  end

  rtl do
    build do
      input :register_block, :value_in,
            name:       "i_#{bit_field.name}",
            data_type:  :logic,
            width:      width,
            dimensions: dimensions
    end

    generate_code_from_template :bit_field
  end

  ral do
    hdl_path { "g_#{bit_field.name}.u_bit_field.i_value" }
  end
end
