class RGen::Configuration::Item < RGen::InputBase::Item
  def error(message = nil)
    raise RGen::ConfigurationError, message
  end
  private :error
end
