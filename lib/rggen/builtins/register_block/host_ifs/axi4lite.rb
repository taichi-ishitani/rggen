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
    build do
      parameter :register_block, :access_priority,
        name:      'ACCESS_PRIORITY',
        data_type: :'rggen_rtl_pkg::rggen_direction',
        default:   :'rggen_rtl_pkg::RGGEN_WRITE'
      if unfold_sv_interface_port?
        input :register_block, :awvalid,
          name: 'i_awvalid', data_type: :logic, width: 1
        output :register_block, :awready,
          name: 'o_awready', data_type: :logic, width: 1
        input :register_block, :awaddr,
          name: 'i_awaddr', data_type: :logic, width: local_address_width
        input :register_block, :awprot,
          name: 'i_awprot', data_type: :logic, width: 3
        input :register_block, :wvalid,
          name: 'i_wvalid', data_type: :logic, width: 1
        output :register_block, :wready,
          name: 'o_wready', data_type: :logic, width: 1
        input :register_block, :wdata,
          name: 'i_wdata', data_type: :logic, width: data_width
        input :register_block, :wstrb,
          name: 'i_wstrb', data_type: :logic, width: data_width / 8
        output :register_block, :bvalid,
          name: 'o_bvalid', data_type: :logic, width: 1
        input :register_block, :bready,
          name: 'i_bready', data_type: :logic, width: 1
        output :register_block, :bresp,
          name: 'o_bresp', data_type: :logic, width: 2
        input :register_block, :arvalid,
          name: 'i_arvalid', data_type: :logic, width: 1
        output :register_block, :arready,
          name: 'o_arready', data_type: :logic, width: 1
        input :register_block, :araddr,
          name: 'i_araddr', data_type: :logic, width: local_address_width
        input :register_block, :arprot,
          name: 'i_arprot', data_type: :logic, width: 3
        output :register_block, :rvalid,
          name: 'o_rvalid', data_type: :logic, width: 1
        input :register_block, :rready,
          name: 'i_rready', data_type: :logic, width: 1
        output :register_block, :rdata,
          name: 'o_rdata', data_type: :logic, width: data_width
        output :register_block, :rresp,
          name: 'o_rresp', data_type: :logic, width: 2
        interface :register_block, :axi4lite_if,
          type: :rggen_axi4lite_if,
          parameters: [local_address_width, data_width]
      else
        interface_port :register_block, :axi4lite_if,
          type:    :rggen_axi4lite_if,
          modport: :slave
      end
    end

    generate_code :register_block do |code|
      unfold_sv_interface_port? && axi4lite_if_assignment(code)
      code << process_template
    end

    def axi4lite_if_assignment(code)
      code << assign("#{axi4lite_if}.awvalid", awvalid) << nl
      code << assign(awready, "#{axi4lite_if}.awready") << nl
      code << assign("#{axi4lite_if}.awaddr" , awaddr ) << nl
      code << assign("#{axi4lite_if}.awprot" , awprot ) << nl
      code << assign("#{axi4lite_if}.wvalid" , wvalid ) << nl
      code << assign(wready , "#{axi4lite_if}.wready" ) << nl
      code << assign("#{axi4lite_if}.wdata"  , wdata  ) << nl
      code << assign("#{axi4lite_if}.wstrb"  , wstrb  ) << nl
      code << assign(bvalid , "#{axi4lite_if}.bvalid" ) << nl
      code << assign("#{axi4lite_if}.bready" , bready ) << nl
      code << assign(bresp  , "#{axi4lite_if}.bresp"  ) << nl
      code << assign("#{axi4lite_if}.arvalid", arvalid) << nl
      code << assign(arready, "#{axi4lite_if}.arready") << nl
      code << assign("#{axi4lite_if}.araddr" , araddr ) << nl
      code << assign("#{axi4lite_if}.arprot" , arprot ) << nl
      code << assign(rvalid , "#{axi4lite_if}.rvalid" ) << nl
      code << assign("#{axi4lite_if}.rready" , rready ) << nl
      code << assign(rdata  , "#{axi4lite_if}.rdata"  ) << nl
      code << assign(rresp  , "#{axi4lite_if}.rresp"  ) << nl
    end
  end
end
