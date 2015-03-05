RGen.item(:register_block, :name) do
  register_map do
    field :name

    build do |cell|
      @name = cell.to_s
      unless @name.verilog_identifer?
        error "invalid value for register block name: #{cell.inspect}"
      end
      if register_map.register_blocks.any? {|block| @name == block.name}
        error "repeated register block name: #{@name}"
      end
    end
  end
end
