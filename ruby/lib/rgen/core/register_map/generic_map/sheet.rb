class RGen::RegisterMap::GenericMap::Sheet
  def initialize(map, name)
    @map  = map
    @name = name
  end

  attr_reader :name
end
