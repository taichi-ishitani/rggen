class RGen::Configuration::Item < RGen::InputBase::Item
  private

  def error(message = nil)
    fail RGen::ConfigurationError, message
  end
end
