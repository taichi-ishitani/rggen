module RGen::RegisterMap::Register
  class Item < RGen::RegisterMap::Base::Item
    def register_map
      register_block.register_map
    end

    def register_block
      register.register_block
    end

    def register
      owner
    end
  end
end
