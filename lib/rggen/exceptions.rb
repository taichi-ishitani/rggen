module RgGen
  class RgGenError < StandardError
  end

  class BuilderError < RgGenError
  end

  class RuntimeError < RgGenError
  end

  class LoadError < RgGen::RuntimeError
  end

  class ConfigurationError < RgGen::RuntimeError
  end

  class RegisterMapError < RgGen::RuntimeError
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
