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
