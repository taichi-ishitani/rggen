module RGen::Configuration
  module RaiseError
    private

    def error(message = nil)
      fail RGen::ConfigurationError, message
    end
  end
end
