define_simple_item :register_block, :top_module do
  rtl do
    write_file '<%= register_block.name %>.sv' do |f|
      f.body { source_file_body }
    end

    def source_file_body
      module_definition register_block.name do |m|
        m.parameters register_block.parameter_declarations
        m.ports      register_block.port_declarations
        m.signals    register_block.signal_declarations
        m.body { |code| module_body(code) }
      end
    end

    def module_body(code)
      register_block.generate_code(:module_item, :top_down, code)
    end
  end
end
