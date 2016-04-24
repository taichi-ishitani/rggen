simple_item :bit_field, :field_model do
  ral do
    export :model_creation

    delegate [:name, :width, :lsb, :access] => :bit_field

    build do
      model_declaration :rggen_ral_field, name
    end

    def model_creation(code)
      code << "`rggen_ral_create_field_model(#{arguments.join(', ')})" << nl
    end

    def arguments
      [name, string(name), width, lsb, access, volatile, reset, has_reset]
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
  end
end
