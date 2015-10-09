module RGen::Structure::BitField
  module Item
    def register_map
      register_block.parent
    end

    def register_block
      register.parent
    end

    def register
      bit_field.parent
    end

    def bit_field
      owner
    end
  end
end
