define_simple_item :register_block, :signal_declarations do
  rtl do
    generate_code :module_item do |buffer|
      register_block.signal_declarations.each do |declaration|
        buffer << declaration << semicolon << nl
      end
    end
  end
end
