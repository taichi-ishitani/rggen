simple_item :register_block, :block_model_definition do
  ral do
    generate_code :package_item do
      class_definition model_name do |c|
        c.base :rgen_ral_block
        c.body { |code| body_code(code) }
      end
    end

    def model_name
      "#{register_block.name}_block_model"
    end

    def body_code(code)
      register_block.generate_code(:block_model_item, :top_down, code)
    end
  end
end
