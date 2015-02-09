class RGen::Configuration::Item < RGen::InputBase::Item
  def error(message = nil)
    fail RGen::ConfigurationError, message
  end
  private :error
end
