list_item :register, :type, :external do
  register_map do
    read_write
    required_byte_size any_size
    need_no_bit_fields
  end

  rtl do
    delegate [:unfold_sv_interface_port?] => :configuration
    delegate [:name] => :register

    build do
      if unfold_sv_interface_port?
        output :register_block, :request,
          name: "o_#{name}_request", data_type: :logic, width: 1
        output :register_block, :address,
          name: "o_#{name}_address", data_type: :logic, width: address_width
        output :register_block, :direction,
          name: "o_#{name}_direction", data_type: :logic, width: 1
        output :register_block, :write_data,
          name: "o_#{name}_write_data", data_type: :logic, width: data_width
        output :register_block, :strobe,
          name: "o_#{name}_strobe", data_type: :logic, width: data_width / 8
        input :register_block, :done,
          name: "i_#{name}_done", data_type: :logic, width: 1
        input :register_block, :write_done,
          name: "i_#{name}_write_done", data_type: :logic, width: 1
        input :register_block, :read_done,
          name: "i_#{name}_read_done", data_type: :logic, width: 1
        input :register_block, :read_data,
          name: "i_#{name}_read_data", data_type: :logic, width: data_width
        input :register_block, :status,
          name: "i_#{name}_status", data_type: :logic, width: 2
        interface :register, :bus_if,
          type: :rggen_bus_if, parameters: [address_width, data_width]

      else
          interface_port :register_block, :bus_if,
            name: "#{name}_bus_if", type: :rggen_bus_if, modport: :master
      end
    end

    def address_width
      Math.clog2(address_range.end - address_range.begin + 1)
    end

    generate_code :register do |code|
      unfold_sv_interface_port? && bus_if_assignment(code)
      code << process_template
    end

    def bus_if_assignment(code)
      code << assign(request   , "#{bus_if}.request"     ) << nl
      code << assign(address   , "#{bus_if}.address"     ) << nl
      code << assign(direction , "#{bus_if}.direction"   ) << nl
      code << assign(write_data, "#{bus_if}.write_data"  ) << nl
      code << assign(strobe    , "#{bus_if}.write_strobe") << nl
      code << assign("#{bus_if}.done"      , done         ) << nl
      code << assign("#{bus_if}.write_done", write_done   ) << nl
      code << assign("#{bus_if}.read_done" , read_done    ) << nl
      code << assign("#{bus_if}.read_data" , read_data    ) << nl
      code << assign("#{bus_if}.status"    , casted_status) << nl
    end

    def casted_status
      "rggen_rtl_pkg::rggen_status'(#{status})"
    end
  end

  c_header do
    delegate [:name, :byte_size] => :register

    address_struct_member do
      "RGGEN_EXTERNAL_REGISTERS(#{byte_size}, #{name.upcase}) #{name}"
    end
  end
end
