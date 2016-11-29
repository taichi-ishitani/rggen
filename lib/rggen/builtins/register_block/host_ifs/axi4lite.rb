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
      parameter :write_priority, name: 'WRITE_PRIORITY', default: 1
      group :axi4lite do
        input  :awvalid, name: 'i_awvalid', width: 1
        output :awready, name: 'o_awready', width: 1
        input  :awaddr , name: 'i_awaddr' , width: address_width
        input  :awprot , name: 'i_awprot' , width: 3
        input  :wvalid , name: 'i_wvalid' , width: 1
        output :wready , name: 'o_wready' , width: 1
        input  :wdata  , name: 'i_wdata'  , width: data_width
        input  :wstrb  , name: 'i_wstrb'  , width: byte_width
        output :bvalid , name: 'o_bvalid' , width: 1
        input  :bready , name: 'i_bready' , width: 1
        output :bresp  , name: 'o_bresp'  , width: 2
        input  :arvalid, name: 'i_arvalid', width: 1
        output :arready, name: 'o_arready', width: 1
        input  :araddr , name: 'i_araddr' , width: address_width
        input  :arprot , name: 'i_arprot' , width: 3
        output :rvalid , name: 'o_rvalid' , width: 1
        input  :rready , name: 'i_rready' , width: 1
        output :rdata  , name: 'o_rdata'  , width: data_width
        output :rresp  , name: 'o_rresp'  , width: 2
      end
    end

    generate_code_from_template :module_item
  end
end
