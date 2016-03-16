define_simple_item :register_block, :module_declaration do
  rtl do
    write_file '<%= register_block.name %>.sv' do
      module_declaration register_block.name do |m|
        m.parameters register_block.parameter_declarations
        m.ports      register_block.port_declarations
        m.body do |code|
          register_block.generate_code(:module_item, :top_down, code)
        end
      end
    end
  end
end
