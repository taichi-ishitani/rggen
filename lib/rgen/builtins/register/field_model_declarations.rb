simple_item :register, :field_model_declarations do
  ral do
    generate_code :reg_model_item do |buffer|
      register.generate_code(:field_model_declaration, :top_down, buffer)
    end
  end
end
