simple_item :register, :rtl_top do
  rtl do
    export :index
    export :local_index
    export :loop_variables
    export :loop_variable

    delegate [:array?, :dimensions] => :register

    generate_code :register_block do
      local_scope "g_#{register.name}" do |s|
        s.signals register.signal_declarations(:register)
        s.loops loops
        s.body { |c| register.generate_code(:register, :top_down, c) }
      end
    end

    def index
      return base_index unless array?
      "#{base_index}+#{local_index}"
    end

    def local_index
      return nil unless array?
      local_index_terms(0).join('+')
    end

    def loop_variables
      return nil unless array?
      dimensions.size.times.map(&method(:loop_variable))
    end

    def loop_variable(level)
      return nil unless array?
      return nil if level >= dimensions.size
      @loop_variables ||= Hash.new do |h, l|
        h[l]  = create_identifier("g_#{loop_index(l)}")
      end
      @loop_variables[level]
    end

    private

    def base_index
      former_registers.sum(0, &:count)
    end

    def former_registers
      register_block.registers.take_while { |r| !register.equal?(r) }
    end

    def local_index_terms(level)
      if level < (dimensions.size - 1)
        partial_count = dimensions[(level + 1)..-1].inject(&:*)
        local_index_terms(level + 1).unshift(
          [partial_count, :'*', loop_variable(level)].join
        )
      else
        [loop_variable(level)]
      end
    end

    def loops
      return nil unless array?
      Hash[*loop_variables.zip(dimensions).flatten]
    end
  end
end
