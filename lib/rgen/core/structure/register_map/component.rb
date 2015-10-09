module RGen::Structure::RegisterMap
  module Component
    def register_blocks
      children
    end

    def registers
      register_blocks.flat_map(&:children)
    end

    def bit_fields
      registers.flat_map(&:children)
    end
  end
end
