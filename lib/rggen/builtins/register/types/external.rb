list_item :register, :type, :external do
  register_map do
    read_write
    required_byte_size any_size
    need_no_bit_fields
  end
end
