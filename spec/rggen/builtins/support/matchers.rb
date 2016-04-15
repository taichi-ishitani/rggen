RSpec::Matchers.define :match_access do |expected_access|
  match do |bit_field|
    case expected_access
    when :read_write
      readable  = true
      writable  = true
    when :read_only
      readable  = true
      writable  = false
    when :write_only
      readable  = false
      writable  = true
    when :reserved
      readable  = false
      writable  = false
    end

    return false if bit_field.readable?   != readable
    return false if bit_field.writable?   != writable
    return false if bit_field.read_only?  != ( readable && !writable)
    return false if bit_field.write_only? != (!readable &&  writable)
    return false if bit_field.reserved?   != (!readable && !writable)
    true
  end
end

RSpec::Matchers.define :match_identifier do |expected_name|
  match do |identifier|
    next false unless identifier.is_a?(RgGen::OutputBase::VerilogUtility::Identifier)
    identifier.to_s == expected_name
  end
end

RSpec::Matchers.define :have_identifier do |*expectation|
  match do |component|
    if expectation.size == 3
      group       = expectation[0]
      handle_name = expectation[1]
      attributes  = expectation[2]
    else
      group       = nil
      handle_name = expectation[0]
      attributes  = expectation[1]
    end

    identifier  = get_identifier(component, group, handle_name)
    return false if identifier.nil?
    return false if identifier.to_s != (attributes[:name] || handle_name).to_s
    return true
  end

  def get_identifier(component, group_name, handle_name)
    return nil if group_name && component.not.respond_to?(group_name)
    context = (group_name && component.__send__(group_name)) || component
    return nil unless context.respond_to?(handle_name)
    context.__send__(handle_name)
  end
end

RSpec::Matchers.define :have_port_declaration do |attributes|
  match do |component|
    expectation = RgGen::OutputBase::VerilogUtility::Declaration.new(:port, attributes).to_s
    component.port_declarations.any? { |declaration| declaration.to_s == expectation }
  end
end

RSpec::Matchers.define :have_signal_declaration do |attributes|
  match do |component|
    expectation = RgGen::OutputBase::VerilogUtility::Declaration.new(:variable, attributes).to_s
    component.signal_declarations.any? { |declaration| declaration.to_s == expectation }
  end
end

RSpec::Matchers.define :generate_code do |kind, mode, expected_code|
  diffable

  match do |component|
    @expected = expected_code
    generate_code(component, kind, mode)
    actual.include?(expected)
  end

  failure_message do |component|
    "#{component} does not generate expected code."
  end

  attr_reader :expected

  def generate_code(component, kind, mode)
    buffer  = RgGen::OutputBase::CodeBlock.new
    component.generate_code(kind, mode, buffer)
    @actual = buffer.to_s
  end
end
