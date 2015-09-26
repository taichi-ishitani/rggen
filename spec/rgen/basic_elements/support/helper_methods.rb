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

def match_address(start_address, end_address)
  byte_size = end_address - start_address + 1
  have_attributes(start_address: start_address, end_address: end_address, byte_size: byte_size)
end

def match_byte_size(byte_size)
  have_attributes(byte_size: byte_size)
end

def match_bit_assignment(msb, lsb)
  width = msb - lsb + 1
  have_attributes(msb: msb, lsb: lsb, width: width)
end

def match_initial_value(value)
  have_attributes(initial_value: value)
end

def clear_enabled_items
  RGen.generator.builder.categories.each_value do |category|
    category.instance_variable_get(:@item_stores).each_value do |item_registry|
      item_registry.instance_variable_get(:@enabled_items).clear
    end
  end
end
