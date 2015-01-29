module RGen
  class RGenError < StandardError
  end

  class LoadError < RGenError
  end

  class ConfigurationError < RGenError
  end
end
