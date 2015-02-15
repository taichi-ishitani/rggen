module RGen
  class RGenError < StandardError
  end

  class LoadError < RGenError
  end

  class ConfigurationError < RGenError
  end

  class RegisterMapError < RGenError
    def initialize(message, position)
      super(message)
      @position = position
    end

    attr_reader :position
  end
end
