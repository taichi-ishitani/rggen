simple_item :register_block, :reg_model_creator do
  ral do
    generate_code :block_model_item do
      function_definition :create_registers do |f|
        f.return_type :void
        f.body { |code| function_body(code) }
      end
    end

    def function_body(code)
      register_block.registers.each { |r| r.model_creation(code) }
    end
  end
end
