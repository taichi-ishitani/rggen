def match_address_width(width)
  have_attributes(address_width: width)
end

def match_data_width(width)
  byte_width  = width / 8
  have_attributes(data_width: width, byte_width: byte_width)
end

def match_name(name)
  have_attributes(name: name)
end

def match_base_address(start_address, end_address)
  byte_size           = end_address - start_address + 1
  local_address_width = Math.clog2(byte_size)
  have_attributes(start_address: start_address, end_address: end_address, byte_size: byte_size, local_address_width: local_address_width)
end

def match_offset_address(start_address, end_address)
  byte_size = end_address - start_address + 1
  have_attributes(start_address: start_address, end_address: end_address, byte_size: byte_size)
end

def match_bit_assignment(msb, lsb)
  width = msb - lsb + 1
  have_attributes(msb: msb, lsb: lsb, width: width)
end
