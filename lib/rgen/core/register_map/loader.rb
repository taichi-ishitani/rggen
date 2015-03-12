module RGen::RegisterMap
  class Loader < RGen::InputBase::Loader
    private

    def create_map(file, &block)
      map = GenericMap.new(file)
      block.call(map) if block_given?
      map
    end
  end
end
