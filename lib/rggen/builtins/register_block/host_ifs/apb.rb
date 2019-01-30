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
      if unfold_sv_interface_port?
        input :register_block, :psel,
          name: 'i_psel', data_type: :logic, width: 1
        input :register_block, :penable,
          name: 'i_penable', data_type: :logic, width: 1
        input :register_block, :paddr,
          name: 'i_paddr', data_type: :logic, width: local_address_width
        input :register_block, :pprot,
          name: 'i_pprot', data_type: :logic, width: 3
        input :register_block, :pwrite,
          name: 'i_pwrite', data_type: :logic, width: 1
        input :register_block, :pwdata,
          name: 'i_pwdata', data_type: :logic, width: data_width
        input :register_block, :pstrb,
          name: 'i_pstrb', data_type: :logic, width: data_width / 8
        output :register_block, :pready,
          name: 'o_pready', data_type: :logic, width: 1
        output :register_block, :prdata,
          name: 'o_prdata', data_type: :logic, width: data_width
        output :register_block, :pslverr,
          name: 'o_pslverr', data_type: :logic, width: 1
        interface :register_block, :apb_if,
          type: :rggen_apb_if, parameters: [local_address_width, data_width]
      else
        interface_port :register_block, :apb_if,
          type: :rggen_apb_if, modport:  :slave
      end
    end

    generate_code :register_block do |code|
      unfold_sv_interface_port? && apb_if_assignment(code)
      code << process_template
    end

    def apb_if_assignment(code)
      code << assign("#{apb_if}.psel"   , psel   ) << nl
      code << assign("#{apb_if}.penable", penable) << nl
      code << assign("#{apb_if}.paddr"  , paddr  ) << nl
      code << assign("#{apb_if}.pprot"  , pprot  ) << nl
      code << assign("#{apb_if}.pwrite" , pwrite ) << nl
      code << assign("#{apb_if}.pwdata" , pwdata ) << nl
      code << assign("#{apb_if}.pstrb"  , pstrb  ) << nl
      code << assign(pready , "#{apb_if}.pready" ) << nl
      code << assign(prdata , "#{apb_if}.prdata" ) << nl
      code << assign(pslverr, "#{apb_if}.pslverr") << nl
    end
  end
end
