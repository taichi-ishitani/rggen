RSpec::Matchers.define :match_type do |expected_attributes|
  match do |bit_field|
    type      = expected_attributes[:type]
    readable  = (expected_attributes.key?(:readable)) ? expected_attributes[:readable] : true
    writable  = (expected_attributes.key?(:writable)) ? expected_attributes[:writable] : true

    return false if bit_field.type        != type
    return false if bit_field.readable?   != readable
    return false if bit_field.writable?   != writable
    return false if bit_field.read_only?  != ( readable && !writable)
    return false if bit_field.write_only? != (!readable &&  writable)
    return false if bit_field.reserved?   != (!readable && !writable)
    true
  end
end
