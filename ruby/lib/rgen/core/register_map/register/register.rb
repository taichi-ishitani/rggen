module RGen::RegisterMap::Register
  class Register < RGen::InputBase::Component
    def register_map
      register_block.register_map
    end

    def register_block
      parent
    end

    def bit_fields
      children
    end
  end
end
