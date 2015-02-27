module RGen::RegisterMap
  class Loader < RGen::InputBase::Loader
    private

    def create_map(file)
      GenericMap.new(file)
    end
  end
end
