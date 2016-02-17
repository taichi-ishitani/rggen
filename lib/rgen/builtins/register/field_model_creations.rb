simple_item :register, :field_model_creations do
  ral do
    generate_code_from_template :reg_model_item

    def function_body(buffer)
      register.bit_fields.each_with_index do |bit_field, i|
        buffer << nl if i > 0
        buffer << bit_field.generate_code(:field_model_creation, :top_down)
      end
    end
  end
end
