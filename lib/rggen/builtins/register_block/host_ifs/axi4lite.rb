list_item :register_block, :host_if, :axi4lite do
  configuration do
    validate do
      unless [32, 64].include?(configuration.data_width)
        error 'axi4lite supports either 32 or 64 bits data width only' \
              ": #{configuration.data_width}"
      end
    end
  end

  rtl do
    delegate [
      :address_width, :data_width, :byte_width
    ] => :configuration
    delegate [
      :local_address_width, :clock, :reset
    ] => :register_block

    build do
      parameter :access_priority,
                name:    'ACCESS_PRIORITY',
                type:    :'rggen_rtl_pkg::rggen_direction',
                default: :'rggen_rtl_pkg::RGGEN_WRITE'
      interface_port :axi4lite_if,
                     type:    :rggen_axi4lite_if,
                     modport: :slave
    end

    generate_code_from_template :module_item
  end
end
