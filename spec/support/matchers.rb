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
    rescue RgGen::LoadError => e
      e.message == expected_message
    else
      false
    end
  end
end

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
    rescue RgGen::ConfigurationError => e
      e.message == expected_message
    else
      false
    end
  end
end

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
    rescue RgGen::RegisterMapError => e
      e.to_s == "#{expected_message} -- #{expected_position}"
    else
      false
    end
  end
end

RSpec::Matchers.define :exit_with_code do |code|
  def supports_block_expectations?
    true
  end

  actual  = nil

  match do |block|
    begin
      block.call
    rescue SystemExit => e
      actual  = e.status
    end

    actual && actual == code
  end

  failure_message do
    if actual
      "expected to exit with code (#{code}) but exited with code #{actual}"
    else
      "expected to exit but not exited"
    end
  end
end

RSpec::Matchers.define :match_string do |expected|
  match do |actual|
    values_match?(expected, actual) || values_match?(expected, actual.to_s)
  end
end

RSpec::Matchers.define :write_binary_files do |expectations|
  match do |given_block|
    setup(expectations)
    verify(given_block)
  end

  failure_message do
    messages  = []
    @expected_files.each_with_index do |file, i|
      if !@receive_matcher_results[i]
        messages  << not_written_message(file)
      elsif !@content_comparison_results[i]
        messages  << diff_message(file, @expected_contens[i], @actual_contents[i])
      end
    end
    messages.join("\n")
  end

  match_when_negated do |given_block|
    expect(File).not_to receive(:binwrite)
    given_block.call
    true
  end

  def supports_block_expectations?
    true
  end

  def setup(expectations)
    @expected_files     = expectations.map { |f, _| f }
    @expected_contens   = expectations.map { |_, c| c }
    @expected_as_array  = @expected_files
    @receive_matchers   = []
    @file_streams       = []
    setup_file_doubles
  end

  def setup_file_doubles
    @expected_files.each do |f|
      setup_file_double(f)
    end
  end

  def setup_file_double(file)
    @file_streams  << StringIO.new.tap do |file_stream|
      @receive_matchers << (expect(File).to receive(:binwrite).with(match_string(file), any_args).and_wrap_original do |m, *args|
        file_stream.write(args[1])
      end)
    end
  end

  def verify(given_block)
    given_block.call
    @receive_matcher_results    = @receive_matchers.map(&:expected_messages_received?)
    @actual_contents            = @file_streams.map(&:string)
    @content_comparison_results = @expected_contens.zip(@actual_contents).map { |e, a| values_match?(e, a) }
    @receive_matcher_results.all? && @content_comparison_results.all?
  end

  def not_written_message(file)
    "file: #{file} was expected to be written but was not written\n"
  end

  def diff_message(file, expected, actual)
    actual  = "#{actual}\n" if actual.lines.size < 2
    message = "file: #{file} was written but contents were not matched:"
    ::RSpec::Matchers::ExpectedsForMultipleDiffs.from(expected).message_with_diff(message, ::RSpec::Expectations.differ, actual)
  end
end
