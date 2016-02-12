simple_item :bit_field, :bit_field_model_declaration do
  ral do
    delegate [:name] => :bit_field

    generate_code :bit_field_model_declaration do |buffer|
      buffer << model_declaration(:rgen_ral_field, name) << semicolon
    end
  end
end
