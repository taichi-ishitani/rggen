simple_item :register_block, :reg_model_declarations do
  ral do
    generate_code :block_model_item do |buffer|
      register_block.generate_code(:reg_model_declaration, :top_down, buffer)
    end
  end
end
