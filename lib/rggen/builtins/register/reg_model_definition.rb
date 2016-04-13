simple_item :register, :reg_model_definition do
  ral do
    export :model_name

    generate_code :package_item do
      class_definition model_name do |c|
        c.base base_model
        c.body do |buffer|
          register.generate_code(:reg_model_item, :top_down, buffer)
        end
      end
    end

    def model_name
      "#{register.name}_reg_model"
    end

    def base_model
      (register.shadow? && :rggen_ral_shadow_reg) || :rggen_ral_reg
    end
  end
end
