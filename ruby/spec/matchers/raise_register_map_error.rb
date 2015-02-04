RSpec::Matchers.define :raise_register_map_error do |expected_message, expected_position|
  def supports_block_expectations?
    true
  end

  match do |given_proc|
    unless Proc === given_proc
      return false
    end

    begin
      given_proc.call
    rescue RGen::RegisterMapError => e
      e.message == expected_message && e.position == expected_position
    else
      false
    end
  end
end
