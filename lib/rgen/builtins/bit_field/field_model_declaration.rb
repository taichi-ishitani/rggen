simple_item :bit_field, :field_model_declaration do
  ral do
    delegate [:name] => :bit_field

    generate_code :field_model_declaration do |buffer|
      buffer << model_declaration(:rgen_ral_field, name) << semicolon << nl
    end
  end
end
