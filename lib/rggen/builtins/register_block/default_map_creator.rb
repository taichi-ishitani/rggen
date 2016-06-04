simple_item :register_block, :default_map_creator do
  ral do
    generate_code :block_model_item do
      function_definition :create_default_map do |f|
        f.return_type :uvm_reg_map
        f.body do |code|
          code << :return
          code << space
          code << subroutine_call(:create_map, arguments)
          code << semicolon
        end
      end
    end

    def arguments
      [name, base_address, n_bytes, endian, byte_addressing]
    end

    def name
      string(:default_map)
    end

    def base_address
      0
    end

    def n_bytes
      configuration.byte_width
    end

    def endian
      :UVM_LITTLE_ENDIAN
    end

    def byte_addressing
      1
    end
  end
end
