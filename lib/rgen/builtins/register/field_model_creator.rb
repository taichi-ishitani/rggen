simple_item :register, :field_model_creator do
  ral do
    generate_code :reg_model_item do
      function :create_fields do |f|
        f.return_type :void
        f.body { register.generate_code(:field_model_creation, :top_down) }
      end
    end
  end
end
