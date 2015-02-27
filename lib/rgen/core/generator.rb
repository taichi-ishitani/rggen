module RGen
  class Generator
    def initialize
      @builder  = Builder::Builder.new
    end

    attr_reader :builder
  end
end
