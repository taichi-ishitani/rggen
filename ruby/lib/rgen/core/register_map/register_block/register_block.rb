class RGen::RegisterMap::RegisterBlock::RegisterBlock < RGen::InputBase::Component
  def register_map
    parent
  end

  def registers
    children
  end
end
