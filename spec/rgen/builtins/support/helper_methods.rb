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

def clear_enabled_items
  RGen.builder.categories.each_value do |category|
    category.instance_variable_get(:@item_stores).each_value do |item_store|
      item_store.instance_variable_get(:@enabled_entries).clear
      list_item_entries = item_store.instance_variable_get(:@list_item_entries)
      list_item_entries.each_value do |entry|
        entry.instance_variable_get(:@enabled_items).clear
      end
    end
  end
end

def clear_dummy_list_items(list_name, items)
  RGen.builder.categories.each_value do |category|
    category.instance_variable_get(:@item_stores).each_value do |item_store|
      entry = item_store.instance_variable_get(:@list_item_entries)[list_name]
      next if entry.nil?
      items.each do |item|
        entry.instance_variable_get(:@items).delete(item)
      end
    end
  end
end
