module RGen::Structure::Register
  module Item
    def register_map
      register_block.parent
    end

    def register_block
      register.parent
    end

    def register
      owner
    end
  end
end
