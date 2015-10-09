module RGen::Structure::Register
  module Component
    def register_map
      register_block.parent
    end

    def register_block
      parent
    end

    def bit_fields
      children
    end
  end
end
