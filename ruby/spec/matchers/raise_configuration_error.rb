RSpec::Matchers.define :raise_configuration_error do |expected_message|
  def supports_block_expectations?
    true
  end

  match do |given_proc|
    unless Proc === given_proc
      return false
    end

    begin
      given_proc.call
    rescue RGen::ConfigurationError => e
      e.message == expected_message
    else
      false
    end
  end
end
