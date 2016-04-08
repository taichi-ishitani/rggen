simple_item :register, :reg_model_creation do
  ral do
    delegate [:byte_width] => :configuration
    delegate [:local_address_width] => :register_block
    delegate [:name, :dimensions, :array?, :shadow?] => :register

    generate_code :reg_model_creation  do |buffer|
      foreach_header(buffer) if array?
      model_creation(buffer)
      foreach_footer(buffer) if array?
    end

    def foreach_header(buffer)
      buffer << "foreach (#{name}[#{loop_varibles.join(', ')}]) begin" << nl
      buffer.indent += 2
    end

    def model_creation(buffer)
      buffer << "`rgen_ral_create_reg_model(#{arguments.join(', ')})" << nl
    end

    def foreach_footer(buffer)
      buffer.indent -= 2
      buffer << 'end' << nl
    end

    def arguments
      [handle, string(name), array_index, offset_address, rights, unmapped]
    end

    def handle
      create_identifier(name)[loop_varibles]
    end

    def array_index
      return '\'{}' unless array?
      array(*loop_varibles)
    end

    def offset_address
      base  = hex(register.start_address, local_address_width)
      if !array? || shadow?
        base
      else
        "#{base} + #{byte_width} * #{loop_varibles.first}"
      end
    end

    def rights
      return string(:RO) if register.read_only?
      return string(:WO) if register.write_only?
      string(:RW)
    end

    def unmapped
      (shadow? && 1) || 0
    end

    def loop_varibles
      return nil unless array?
      @loop_varibles ||= Array.new(dimensions.size, &method(:loop_index))
    end
  end
end
