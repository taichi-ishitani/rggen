list_item :bit_field, :type, :reserved  do
  register_map do
    reserved
  end

  rtl do
    generate_code_from_template :bit_field

    def default_value
      hex(0, width)
    end
  end

  ral do
    access :ro
    hdl_path { "g_#{bit_field.name}.u_bit_field.i_value" }
  end
end
