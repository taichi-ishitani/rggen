simple_item :register_block, :address_struct do
  c_header do
    delegate [:data_width, :byte_width] => :configuration
    delegate [:registers, :name] => :register_block

    generate_code :c_header_item do
      struct_definition(stuct_name) do |s|
        s.with_typedef
        s.members address_struct_members
      end
    end

    def stuct_name
      "s_#{name}_address_struct"
    end

    def address_struct_members
      address_struct_entries.each_cons(2).with_object([]) do |entries, members|
        dummy_size  = entries[1].start_address - entries[0].end_address - 1
        members << dummy_member(dummy_size) if dummy_size > 0
        members << entries[1].address_struct_member
      end
    end

    def dummy_member(size)
      variable_declaration(
        data_type:  "rggen_uint#{data_width}",
        name:       "__dummy_#{dummy_index}",
        dimensions: [size / byte_width]
      )
    end

    def dummy_index
      @dummy_index ||= -1
      @dummy_index += 1
    end

    def address_struct_entries
      [].tap do |entries|
        entries << dummy_entry
        entries.concat(non_reserved_registers)
      end
    end

    def dummy_entry
      Object.new.tap do |dummy|
        dummy.attr_singleton_accessor :end_address
        dummy.end_address = -1
      end
    end

    def non_reserved_registers
      registers.reject(&:reserved?).sort_by(&:start_address)
    end
  end
end
