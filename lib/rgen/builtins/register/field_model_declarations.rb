simple_item :register, :field_model_declarations do
  ral do
    generate_code :reg_model_item do |buffer|
      register.bit_fields.each do |bit_field|
        buffer << bit_field.generate_code(:field_model_declaration, :top_down)
        buffer << nl
      end
    end
  end
end
