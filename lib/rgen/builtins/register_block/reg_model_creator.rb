simple_item :register_block, :reg_model_creator do
  ral do
    generate_code :block_model_item do
      function_definition :create_registers do |f|
        f.return_type :void
        f.body { |buffer| function_body(buffer) }
      end
    end

    def function_body(buffer)
      register_block.generate_code(:reg_model_creation, :top_down, buffer)
    end
  end
end
