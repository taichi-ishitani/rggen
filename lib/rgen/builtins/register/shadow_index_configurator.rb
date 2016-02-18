simple_item :register, :shadow_index_configurator do
  ral do
    generate_code :reg_model_item do |buffer|
      buffer << process_template if register.shadow?
    end

    def arguments(shadow_index)
      [
        parent_name(shadow_index),
        index_name(shadow_index),
        index_value(shadow_index)
      ].join(', ')
    end

    def parent_name(shadow_index)
      parent_register = fild_parent_register(shadow_index.name)
      string(parent_register.name)
    end

    def fild_parent_register(index_name)
      index_field = register_block.bit_fields.find do |bit_field|
        bit_field.name == index_name
      end
      index_field.register
    end

    def index_name(shadow_index)
      string(shadow_index.name)
    end

    def index_value(shadow_index)
      if shadow_index.value
        shadow_index.value
      else
        "indexes[#{array_index}]"
      end
    end

    def array_index
      @array_index  ||= -1
      @array_index  += 1
    end
  end
end
