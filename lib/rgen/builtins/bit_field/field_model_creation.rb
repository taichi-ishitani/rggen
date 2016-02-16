simple_item :bit_field, :field_model_creation do
  ral do
    delegate [:name, :width, :lsb, :access] => :bit_field

    generate_code :field_model_creation do |buffer|
      buffer << "`rgen_ral_create_field(#{arguments.join(', ')})"
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
