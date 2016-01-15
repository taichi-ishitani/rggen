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
      @count      = (@dimensions && @dimensions.sum(0)) || 1
      if @dimensions && @dimensions.any?(&:zero?)
        error "0 is not allowed for array dimension: #{cell.inspect}"
      end
    end

    validate do
      case
      when multi_dimensions_array_with_real_register?
        error 'not use multi dimensions array with real register'
      when mismatch_with_own_byte_size?
        error "mismatches with own byte size(#{register.byte_size}):" \
              " #{dimensions}"
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

    def multi_dimensions_array_with_real_register?
      return false unless array?
      return false if register.shadow?
      register.multiple? && dimensions.size > 1
    end

    def mismatch_with_own_byte_size?
      return false unless array?
      return false if register.shadow?
      register.byte_size != dimensions.first * configuration.byte_width
    end
  end

  rtl do
    export :index
    export :local_index

    def index
      (register.array? && "#{base_index}+#{local_index}") || base_index
    end

    def local_index
      (register.array? && genvar) || nil
    end

    def base_index
      previous_registers.map(&:count).sum(0)
    end

    def genvar
      :g_i
    end

    def previous_registers
      register_block.registers.take_while { |r| !register.equal?(r) }
    end

    generate_pre_code :module_item do |buffer|
      register.dimensions.each_with_index do |dimension, level|
        generate_for_begin_code(dimension, level, buffer)
      end if register.array?
    end

    generate_post_code :module_item do |buffer|
      register.dimensions.size.times do
        generate_for_end_code(buffer)
      end if register.array?
    end

    def generate_for_begin_code(dimension, level, buffer)
      buffer << generate_for_header(dimension)
      buffer << ' begin : '
      buffer << block_name(level)
      buffer << nl
      buffer.indent += 2
    end

    def generate_for_end_code(buffer)
      buffer.indent -= 2
      buffer << 'end' << nl
    end

    def generate_for_header(dimension)
      "for (genvar #{genvar} = 0;#{genvar} < #{dimension};#{genvar}++)"
    end

    def block_name(level)
      "gen_#{register.name}_#{level}"
    end
  end
end
