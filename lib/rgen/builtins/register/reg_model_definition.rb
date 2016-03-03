simple_item :register, :reg_model_definition do
  ral do
    export :model_name

    generate_code :package_item do |buffer|
      model_header(buffer)
      model_items(buffer)
      model_footer(buffer)
    end

    def model_name
      "#{register.name}_reg_model"
    end

    def model_header(buffer)
      buffer << "class #{model_name} extends #{base_model};" << nl
    end

    def model_items(buffer)
      indent(buffer, 2) do
        register.generate_code(:reg_model_item, :top_down, buffer)
      end
    end

    def model_footer(buffer)
      buffer << 'endclass' << nl
    end

    def base_model
      (register.shadow? && :rgen_ral_shadow_reg) || :rgen_ral_reg
    end
  end
end
