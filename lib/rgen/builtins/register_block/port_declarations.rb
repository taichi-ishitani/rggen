define_simple_item :register_block, :port_declarations do
  rtl do
    generate_code :port_declarations do |buffer|
      buffer << '('
      declarations(buffer)
      buffer << ')'
    end

    def declarations(buffer)
      indent(buffer, 2) do
        register_block.port_declarations.each_with_index do |declaration, i|
          buffer << comma << nl if i > 0
          buffer << declaration
        end
      end
    end
  end
end
