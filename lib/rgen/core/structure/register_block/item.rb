module RGen::Structure::RegisterBlock
  module Item
    def register_map
      register_block.parent
    end

    def register_block
      owner
    end
  end
end
