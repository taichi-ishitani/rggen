simple_item :register, :reg_model_definition do
  ral do
    export :model_name

    generate_code :package_item do |buffer|
      buffer << "class #{model_name} extends #{base_model};" << nl
      buffer << model_body
      buffer << 'endclass' << nl
    end

    def model_name
      "#{register.name}_reg_model"
    end

    def base_model
      (register.shadow? && :rgen_ral_shadow_reg) || :rgen_ral_reg
    end

    def model_body
      indent(2) do |buffer|
        register.generate_code(:reg_model_item, :top_down, buffer)
      end
    end
  end
end
