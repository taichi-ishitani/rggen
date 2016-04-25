simple_item :register, :field_model_creator do
  ral do
    generate_code :reg_model_item do
      function_definition :create_fields do |f|
        f.return_type :void
        f.body { |code| body_code(code) }
      end
    end

    def body_code(code)
      register.bit_fields.each { |b| b.model_creation(code) }
    end
  end
end
