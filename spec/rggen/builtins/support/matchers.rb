RSpec::Matchers.define :have_item do |*expectation|
  match do |component|
    @actual = component.items
    actual.any? do |item|
      item.is_a? expected_item
    end
  end

  failure_message do
    "Component is expected to have the item(#{expectation.join(', ')}) but does not have it."
  end

  failure_message_when_negated do
    "Component is expected not to have the item(#{expectation.join(', ')}) but has it."
  end

  define_method(:expected_item) do
    @expected_item  ||=
      RgGen.builder.instance_eval do
        @categories[expectation[0]].instance_eval do
          @item_stores[expectation[1]].instance_eval do
            if expectation.size == 4
              @list_item_entries[expectation[2]].instance_eval do
                @items[expectation[3]]
              end
            else
              @simple_item_entries[expectation[2]].item_class
            end
          end
        end
      end
  end
end

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
    next false unless identifier.is_a?(RgGen::VerilogUtility::Identifier)
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

    @actual = get_identifier(component, group, handle_name)
    return false if actual.nil?
    return false if actual.to_s != (attributes[:name] || handle_name).to_s
    return true
  end

  failure_message do
    "expected identifer(#{expected_identifier}) is not defined."
  end

  def get_identifier(component, group_name, handle_name)
    return nil if group_name && component.not.respond_to?(group_name)
    context = (group_name && component.__send__(group_name)) || component
    return nil unless context.respond_to?(handle_name)
    context.__send__(handle_name)
  end

  define_method(:expected_identifier) do
    if expectation.size == 3
      group       = expectation[0]
      handle_name = expectation[1]
      attributes  = expectation[2]
    else
      group       = nil
      handle_name = expectation[0]
      attributes  = expectation[1]
    end
    if attributes.key?(:name)
      "#{[group, handle_name].compact.join('.')}(name: #{attributes[:name]}))"
    else
      "#{[group, handle_name].compact.join('.')}"
    end
  end
end

RSpec::Matchers.define :have_port_declaration do |attributes|
  match do |component|
    @actual = component.port_declarations
    actual.any? { |declaration| declaration.to_s == expectation }
  end

  failure_message do
    "port(#{expectation}) is not declared.\n" \
    "actual declarations: \n#{actual.map(&:to_s).join("\n")}"
  end

  define_method(:expectation) do
    RgGen::VerilogUtility::Declaration.new(:port, attributes).to_s
  end
end

RSpec::Matchers.define :have_signal_declaration do |attributes|
  match do |component|
    @actual = component.signal_declarations
    actual.any? { |declaration| declaration.to_s == expectation }
  end

  failure_message do
    "signal(#{expectation}) is not declared.\n" \
    "actual declarations: \n#{actual.map(&:to_s).join("\n")}"
  end

  define_method(:expectation) do
    RgGen::VerilogUtility::Declaration.new(:variable, attributes).to_s
  end
end

RSpec::Matchers.define :have_parameter_declaration do |domain, attributes|
  match do |component|
    @actual = (domain && component.parameter_declarations(domain)) || component.parameter_declarations
    @actual.any? { |declaration| declaration.to_s == expectation }
  end

  failure_message do
    "parameter(#{expectation}) is not declared.\n" \
    "actual declarations: \n#{actual.map(&:to_s).join("\n")}"
  end

  define_method(:expectation) do
    RgGen::VerilogUtility::Declaration.new(:parameter, attributes).to_s
  end
end

RSpec::Matchers.define :have_variable_declaration do |domain, attributes|
  match do |component|
    @actual = component.variable_declarations(domain)
    @actual.any? { |declaration| declaration.to_s == expectation }
  end

  failure_message do
    "expected variable(#{expectation}) is not declared.\n" \
    "actual declarations: \n#{actual.map(&:to_s).join("\n")}"
  end

  define_method(:expectation) do
    RgGen::VerilogUtility::Declaration.new(:variable, attributes).to_s
  end
end

RSpec::Matchers.define :generate_code do |kind, mode, expected_code|
  diffable

  match do |component|
    @expected = expected_code
    generate_code(component, kind, mode)
    actual.include?(expected)
  end

  failure_message do |actual|
    "#{actual} is not expected code."
  end

  match_when_negated do |component|
    generate_code(component, kind, mode)
    actual.empty?
  end

  failure_message_when_negated do |actual|
    "No generated code is expected\nactual: #{actual}"
  end

  attr_reader :expected

  def generate_code(component, kind, mode)
    buffer  = RgGen::CodeUtility::CodeBlock.new
    component.generate_code(kind, mode, buffer)
    @actual = buffer.to_s
  end
end

