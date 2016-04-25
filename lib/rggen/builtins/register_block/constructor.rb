simple_item :register_block, :constructor do
  ral do
    delegate [:name] => :register_block

    generate_code :block_model_item do
      function_definition :new do |f|
        f.arguments [
          argument(:name, data_type: :string, default: string(name))
        ]
        f.body { 'super.new(name);' }
      end
    end
  end
end
