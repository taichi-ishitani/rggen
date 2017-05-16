list_item :register_block, :host_if, :apb do
  configuration do
    validate do
      if configuration.address_width > 32
        error 'apb supports 32 or less bits address width only' \
              ": #{configuration.address_width}"
      end
      if configuration.data_width > 32
        error 'apb supports 32 or less bits data width only' \
              ": #{configuration.data_width}"
      end
    end
  end

  rtl do
    build do
      interface_port :register_block, :apb_if,
                     type: :rggen_apb_if,
                     modport: :slave
    end

    generate_code_from_template :register_block
  end
end
