simple_item :register_block, :block_model_definition do
  ral do
    generate_code :package_item do
      class_definition model_name do |c|
        c.base :rgen_ral_block
        c.body do |buffer|
          register_block.generate_code(:block_model_item, :top_down, buffer)
        end
      end
    end

    def model_name
      "#{register_block.name}_block_model"
    end
  end
end
