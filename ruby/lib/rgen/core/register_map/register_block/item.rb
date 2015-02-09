class RGen::RegisterMap::RegisterBlock::Item < RGen::RegisterMap::Base::Item
  def register_map
    register_block.register_map
  end

  def register_block
    owner
  end
end
