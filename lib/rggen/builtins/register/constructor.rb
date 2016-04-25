simple_item :register, :constructor do
  ral do
    generate_code :reg_model_item do
      function_definition :new do |f|
        f.arguments [
          argument(:name, data_type: :string, default: string(register.name))
        ]
        f.body { "super.new(name, #{bits}, 0);" }
      end
    end

    def bits
      max_msb = register.bit_fields.map(&:msb).max
      ((max_msb + 8) / 8) * 8
    end
  end
end
