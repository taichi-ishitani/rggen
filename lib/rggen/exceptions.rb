module RgGen
  class RgGenError < StandardError
  end

  class BuilderError < RgGenError
  end

  class RunTimeError < RgGenError
  end

  class LoadError < RunTimeError
  end

  class ConfigurationError < RunTimeError
  end

  class RegisterMapError < RunTimeError
    def initialize(message, position = nil)
      super(message)
      @position = position
    end

    def to_s
      return super.to_s unless @position
      "#{super.to_s} -- #{@position}"
    end
  end
end
