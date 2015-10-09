module RGen::Structure::BitField
  module Component
    def register_map
      register_block.parent
    end

    def register_block
      register.parent
    end

    def register
      parent
    end
  end
end
