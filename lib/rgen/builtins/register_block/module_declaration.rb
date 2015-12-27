define_simple_item :register_block, :module_declaration do
  rtl do
    write_file '<%= register_block.name %>.sv' do |buffer|
      buffer << "module #{register_block.name}" << space
      buffer << parameter_port_declarations
      buffer << ';' << nl
      buffer << module_items
      buffer << 'endmodule' << nl
    end

    def parameter_port_declarations
      register_block.generate_code(:port_declarations, :top_down)
    end

    def module_items
      indent(2) do |buffer|
        register_block.generate_code(:module_item, :top_down, buffer)
      end
    end
  end
end
