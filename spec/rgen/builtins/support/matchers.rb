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
    expectation = RGen::Rtl::PortDeclaration.new(attributes[:name], attributes)
    component.port_declarations.any? do |declaration|
      declaration.name      == expectation.name      &&
      declaration.direction == expectation.direction &&
      declaration.type      == expectation.type      &&
      declaration.width     == expectation.width     &&
      declaration.dimension == expectation.dimension
    end
  end
end
