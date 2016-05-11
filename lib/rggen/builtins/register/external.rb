simple_item :register, :external do
  register_map do
    field :external?

    input_pattern %r{(true)|(false)|()}i, convert_to_string: true

    build do |cell|
      @external = parse(cell)
      register.need_no_children if external?
    end

    validate do
      if (register.array? || register.shadow?) && external?
        error 'not use array/shadow and ' \
              'external register on the same register'
      end
    end

    def parse(cell)
      if pattern_matched?
        captures.first.not_nil?
      else
        error "invalid value for 'external': #{cell.inspect}"
      end
    end
  end
end
