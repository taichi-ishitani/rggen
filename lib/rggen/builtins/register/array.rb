simple_item :register, :array do
  register_map do
    field :array?
    field :dimensions
    field :count

    input_pattern %r{\[(#{number}(?:,#{number})*)\]},
                  match_automatically: false

    build do |cell|
      @dimensions = parse_array_dimensions(cell)
      @array      = @dimensions.not_nil?
      @count      = (@dimensions && @dimensions.inject(&:*)) || 1
      if @dimensions && @dimensions.any?(&:zero?)
        error "0 is not allowed for array dimension: #{cell.inspect}"
      end
    end

    def parse_array_dimensions(cell)
      case
      when cell.nil? || cell.empty?
        nil
      when pattern_match(cell)
        captures.first.split(',').map(&method(:Integer))
      else
        error "invalid value for array dimension: #{cell.inspect}"
      end
    end
  end

  rtl do
    delegate [:array?, :dimensions] => :register

    export :index
    export :local_index
    export :loop_variables
    export :loop_variable

    generate_pre_code :module_item do |code|
      if array?
        generate_header(code)
        generate_for_headers(code)
      end
    end

    generate_post_code :module_item do |code|
      if array?
        generate_for_footers(code)
        generate_footer(code)
      end
    end

    def index
      (array? && "#{base_index}+#{local_index}") || base_index
    end

    def local_index
      return nil unless array?
      local_index_terms(0).join('+')
    end

    def loop_variables
      return nil unless array?
      Array.new(dimensions.size) { |l| loop_variable(l) }
    end

    def loop_variable(level)
      return nil unless array? && level < dimensions.size
      @loop_variables ||= Hash.new do |h, l|
        h[l]  = create_identifier("g_#{loop_index(l)}")
      end
      @loop_variables[level]
    end

    def base_index
      former_registers.sum(0, &:count)
    end

    def former_registers
      register_block.registers.take_while { |r| !register.equal?(r) }
    end

    def local_index_terms(level)
      if level < (dimensions.size - 1)
        partial_count = dimensions[(level + 1)..-1].inject(:*)
        term          = [partial_count, '*', loop_variable(level)].join
        local_index_terms(level + 1).unshift(term)
      else
        [loop_variable(level)]
      end
    end

    def generate_header(code)
      code << "generate if (1) begin : g_#{register.name}" << nl
      code.indent += 2
      code << "genvar #{loop_variables.join(', ')};" << nl
    end

    def generate_for_headers(code)
      dimensions.each_with_index do |dimension, level|
        code << generate_for_header(dimension, level) << nl
        code.indent += 2
      end
    end

    def generate_for_header(dimension, level)
      gv  = loop_variable(level)
      "for (#{gv} = 0;#{gv} < #{dimension};#{gv}++) begin : g"
    end

    def generate_for_footers(code)
      dimensions.size.times do
        code.indent -= 2
        code << :end << nl
      end
    end

    def generate_footer(code)
      code.indent -= 2
      code << :end << space << :endgenerate << nl
    end
  end
end
