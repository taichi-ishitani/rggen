RSpec::Matchers.define :raise_load_error do |expected_message|
  def supports_block_expectations?
    true
  end

  match do |given_proc|
    unless Proc === given_proc
      return false
    end

    begin
      given_proc.call
    rescue RGen::LoadError => e
      e.message == expected_message
    else
      false
    end
  end
end
