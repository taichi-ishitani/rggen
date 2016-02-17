simple_item :register, :reg_model_constructor do
  ral do
    generate_code_from_template :reg_model_item

    def bits
      max_msb = register.bit_fields.map(&:msb).max
      ((max_msb + 8) / 8) * 8
    end
  end
end
