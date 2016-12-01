list_item :register, :type, :external do
  register_map do
    read_write
    need_no_bit_fields

    validate do
      next unless register.array?
      error 'not use array and external register on the same register'
    end
  end
end
