module RGen::RegisterMap
  class RegisterMap < RGen::InputBase::Component
    def register_blocks
      children
    end

    def registers
      register_blocks.flat_map(&:registers)
    end

    def bit_fields
      register_blocks.flat_map(&:bit_fields)
    end
  end
end
