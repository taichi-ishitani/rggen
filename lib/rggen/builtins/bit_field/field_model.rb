simple_item :bit_field, :field_model do
  ral do
    export :model_creation

    delegate [:name, :width, :lsb, :access, :model_name] => :bit_field

    build do
      variable :reg_model, :field_model,
               data_type: model_name,
               name:      name,
               random:    true
    end

    def model_creation(code)
      code << subroutine_call('`rggen_ral_create_field_model', arguments) << nl
    end

    def arguments
      [name, string(name), width, lsb, access, volatile, reset, has_reset, hdl_path]
    end

    def volatile
      0
    end

    def reset
      hex(bit_field.initial_value || 0, width)
    end

    def has_reset
      (bit_field.initial_value? && 1) || 0
    end

    def hdl_path
      string(bit_field.hdl_path)
    end
  end
end
