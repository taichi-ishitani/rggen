define_simple_item :register_block, :signal_declarations do
  rtl do
    generate_code(:module_item) do |buffer|
      register_block.signal_declarations.each do |declaration|
        buffer << declare_signal(declaration) << nl
      end
    end

    def declare_signal(declaration)
      type_width  = [
        declaration.type, declaration.width
      ].reject(&:empty?).join(space)
      "#{type_width} #{declaration.name}#{declaration.dimensions};"
    end
  end
end
