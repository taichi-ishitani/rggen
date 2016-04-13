module RgGen
  class RgGenError < StandardError
  end

  class BuilderError < RgGenError
  end

  class LoadError < RgGenError
  end

  class ConfigurationError < RgGenError
  end

  class RegisterMapError < RgGenError
    def initialize(message, position)
      super(message)
      @position = position
    end

    attr_reader :position
  end
end
