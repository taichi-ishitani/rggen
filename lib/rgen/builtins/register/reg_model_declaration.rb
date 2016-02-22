simple_item :register, :reg_model_declaration do
  ral do
    delegate [:model_name, :name, :dimensions] => :register

    generate_code :reg_model_declaration do |buffer|
      buffer << declaration << semicolon
    end

    def declaration
      model_declaration(model_name, name, dimensions: dimensions)
    end
  end
end
