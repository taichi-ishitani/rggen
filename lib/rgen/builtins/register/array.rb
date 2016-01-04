simple_item :register, :array do
  register_map do
    field :array?
    field :dimensions
    field :count

    build do |cell|
      case cell
      when empty?
        @dimensions = nil
      when /\A\[ *([1-9]\d*) *\]\z/
        @dimensions = Regexp.last_match.captures.map(&:to_i)
      else
        error "invalid value for array dimension: #{cell.inspect}"
      end
      @array  = @dimensions.not_nil?
      @count  = (@dimensions && @dimensions.sum(0)) || 1
    end

    validate do
      case
      when mismatch_with_own_byte_size?
        error "mismatches with own byte size(#{register.byte_size}):" \
              " #{dimensions}"
      end
    end

    def empty?
      ->(v) { v.nil? || v.empty? }
    end

    def mismatch_with_own_byte_size?
      return false unless array?
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
