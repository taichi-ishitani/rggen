simple_item :register, :index do
  rtl do
    export :index

    def index
      register_block.registers.index(&register.method(:equal?))
    end
  end
end
