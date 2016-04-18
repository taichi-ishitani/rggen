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
      group(:apb) do
        input  :paddr  , name: 'i_paddr'  , width: configuration.address_width
        input  :pprot  , name: 'i_pprot'  , width: 3
        input  :psel   , name: 'i_psel'   , width: 1
        input  :penable, name: 'i_penable', width: 1
        input  :pwrite , name: 'i_pwrite' , width: 1
        input  :pwdata , name: 'i_pwdata' , width: configuration.data_width
        input  :pstrb  , name: 'i_pstrb'  , width: configuration.byte_width
        output :pready , name: 'o_pready' , width: 1
        output :prdata , name: 'o_prdata' , width: configuration.data_width
        output :pslverr, name: 'o_pslverr', width: 1
      end
    end

    generate_code_from_template :module_item
  end
end
