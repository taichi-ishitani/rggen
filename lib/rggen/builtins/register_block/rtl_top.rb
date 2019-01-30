define_simple_item :register_block, :rtl_top do
  rtl do
    write_file '<%= register_block.name %>.sv' do |f|
      f.body { source_file_body }
    end

    def source_file_body
      module_definition register_block.name do |m|
        m.parameters   register_block.parameter_declarations(:register_block)
        m.ports        register_block.port_declarations(:register_block)
        m.signals      register_block.signal_declarations(:register_block)
        m.body { |code| module_body(code) }
      end
    end

    def module_body(code)
      register_block.generate_code(:register_block, :top_down, code)
    end

    generate_pre_code :register_block do |code|
      [
        '`define rggen_connect_bit_field_if(RIF, FIF, MSB, LSB) \\',
        'assign  FIF.read_access         = RIF.read_access; \\',
        'assign  FIF.write_access        = RIF.write_access; \\',
        'assign  FIF.write_data          = RIF.write_data[MSB:LSB]; \\',
        'assign  FIF.write_mask          = RIF.write_mask[MSB:LSB]; \\',
        'assign  RIF.value[MSB:LSB]      = FIF.value; \\',
        'assign  RIF.read_data[MSB:LSB]  = FIF.read_data;'
      ].each do |line|
        code  << line << nl
      end
    end

    generate_post_code :register_block do |code|
      code  << :'`undef rggen_connect_bit_field_if' << nl
    end
  end
end
