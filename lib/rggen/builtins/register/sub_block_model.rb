simple_item :register, :sub_block_model do
  ral do
    export :model_creation

    available? { register.external? }

    build do
      parameter :block_model, :model_type,
                data_type: :type,
                name:      type_name,
                default:   :rggen_ral_block
      variable  :block_model, :sub_block_model,
                data_type: type_name,
                name:      register.name,
                random:    true
    end

    def type_name
      register.name.upcase
    end

    def model_creation(code)
      code << "`rggen_ral_create_block_model(#{arguments.join(', ')})" << nl
    end

    def arguments
      [register.name, string(register.name), offset_addess]
    end

    def offset_addess
      hex(register.start_address, register_block.local_address_width)
    end
  end
end
