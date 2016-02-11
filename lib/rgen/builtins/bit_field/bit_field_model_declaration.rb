simple_item :bit_field, :bit_field_model_declaration do
  ral do
    delegate [:name] => :bit_field

    generate_code :bit_field_model_declaration do |buffer|
      buffer << declaratin << semicolon
    end

    def declaratin
      create_declaration(:variable, data_type: :rgen_ral_field, name: name, random: true)
    end
  end
end
