module RGen::Structure::RegisterBlock
  module Component
    def register_map
      parent
    end

    def registers
      children
    end

    def bit_fields
      registers.flat_map(&:children)
    end
  end
end
