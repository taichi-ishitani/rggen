define_simple_item :register_block, :module_declaration do
  rtl do
    write_file '<%= register_block.name %>.sv' do |buffer|
      module_header(buffer)
      module_items(buffer)
      module_footer(buffer)
    end

    def module_header(buffer)
      buffer << "module #{register_block.name}" << space
      register_block.generate_code(:port_declarations, :top_down, buffer)
      buffer << ';' << nl
    end

    def module_items(buffer)
      indent(buffer, 2) do
        register_block.generate_code(:module_item, :top_down, buffer)
      end
    end

    def module_footer(buffer)
      buffer << 'endmodule' << nl
    end
  end
end
