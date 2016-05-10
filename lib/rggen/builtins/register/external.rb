simple_item :register, :external do
  register_map do
    field :external?

    input_pattern %r{(true)|(false)}i, convert_to_string: true

    build do |cell|
      @external = parse(cell)
      register.need_no_children if external?
    end

    def parse(cell)
      case
      when pattern_matched?
        captures.first.not_nil?
      when cell.nil? || cell.empty?
        false
      end
    end
  end
end
