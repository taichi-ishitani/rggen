module RGen::RegisterMap::RegisterBlock
  class RegisterBlock < RGen::InputBase::Component
    def register_map
      parent
    end

    def registers
      children
    end

    def bit_fields
      registers.flat_map(&:bit_fields)
    end
  end
end
