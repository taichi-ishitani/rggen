simple_item :register, :bus_exporter do
  rtl do
    delegate [
      :data_width, :byte_width
    ] => :configuration
    delegate [
      :name, :byte_size, :external?, :index, :external_index
    ] => :register

    available? { external? }

    build do
      output :valid     , name: "o_#{name}_valid"     , width: 1
      output :write     , name: "o_#{name}_write"     , width: 1
      output :read      , name: "o_#{name}_read"      , width: 1
      output :address   , name: "o_#{name}_address"   , width: address_width
      output :strobe    , name: "o_#{name}_strobe"    , width: byte_width
      output :write_data, name: "o_#{name}_write_data", width: data_width
      input  :ready     , name: "i_#{name}_ready"     , width: 1
      input  :status    , name: "i_#{name}_status"    , width: 2
      input  :read_data , name: "i_#{name}_read_data" , width: data_width
    end

    generate_code :module_item do |code|
      code << register_select_connection << nl
      code << process_template
    end

    def address_width
      Math.clog2(byte_size)
    end

    def register_select_connection
      assign(
        register_block.external_register_select[external_index],
        register_block.register_select[index]
      )
    end

    def start_address
      hex(register.start_address, register_block.local_address_width)
    end
  end
end
