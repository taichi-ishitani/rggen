simple_item :register, :index do
  rtl do
    delegate [:array?, :loop_variable] => :register

    export :index
    export :local_index

    def index
      (array? && "#{base_index}+#{local_index}") || base_index
    end

    def local_index
      return nil unless array?
      local_index_terms(0).join('+')
    end

    def base_index
      former_registers.map(&:count).sum(0)
    end

    def former_registers
      register_block.registers.take_while { |r| !register.equal?(r) }
    end

    def local_index_terms(level)
      if level < (register.dimensions.size - 1)
        partial_count = register.dimensions[(level + 1)..-1].inject(:*)
        term          = [partial_count, '*', loop_variable(level)].join
        local_index_terms(level + 1).unshift(term)
      else
        [loop_variable(level)]
      end
    end
  end
end
