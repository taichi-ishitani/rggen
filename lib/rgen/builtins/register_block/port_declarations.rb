define_simple_item :register_block, :port_declarations do
  rtl do
    generate_code :port_declarations do |buffer|
      buffer << '(' << nl
      buffer << declarations
      buffer << nl  << ')'
    end

    def declarations
      indent(2) do |buffer|
        register_block.port_declarations.each_with_index do |declaration, i|
          buffer << comma << nl if i > 0
          buffer << declare_port(declaration)
        end
      end
    end

    def declare_port(declaration)
      [
        declaration.direction,
        declaration.type,
        declaration.width,
        "#{declaration.name}#{declaration.dimension}"
      ].reject(&:empty?).join(space)
    end
  end
end
