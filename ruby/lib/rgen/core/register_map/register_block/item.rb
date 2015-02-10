module RGen::RegisterMap::RegisterBlock
  class Item < RGen::RegisterMap::Base::Item
    def register_map
      register_block.register_map
    end

    def register_block
      owner
    end
  end
end
