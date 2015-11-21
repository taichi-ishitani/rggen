RGen.list_item(:register_block, :host_if, :apb) do
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

    generate_code(:module_item) do |buffer|
      buffer << process_template
    end
  end
end
