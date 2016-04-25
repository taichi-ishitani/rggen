simple_item :register, :reg_model do
  ral do
    export :model_creation

    delegate [:byte_width] => :configuration
    delegate [:local_address_width] => :register_block
    delegate [:name, :dimensions, :array?, :shadow?] => :register

    build do
      model_declaration model_name, name, dimensions: dimensions
    end

    generate_code :package_item do
      class_definition model_name do |c|
        c.base      base_model
        c.variables register.sub_model_declarations
        c.body { |code| body_code(code) }
      end
    end

    def model_creation(code)
      foreach_header(code) if array?
      code << "`rggen_ral_create_reg_model(#{arguments.join(', ')})" << nl
      foreach_footer(code) if array?
    end

    def foreach_header(code)
      code << "foreach (#{name}[#{loop_varibles.join(', ')}]) begin" << nl
      code.indent += 2
    end

    def foreach_footer(code)
      code.indent -= 2
      code << :end << nl
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

    def model_name
      "#{name}_reg_model"
    end

    def base_model
      (register.shadow? && :rggen_ral_shadow_reg) || :rggen_ral_reg
    end

    def body_code(code)
      register.generate_code(:reg_model_item, :top_down, code)
    end
  end
end
