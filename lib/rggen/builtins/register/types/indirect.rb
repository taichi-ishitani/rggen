list_item :register, :type, :indirect do
  register_map do
    field :indexes

    readable? { register.bit_fields.any?(&:readable?) }
    writable? { register.bit_fields.any?(&:writable?) }

    need_options
    support_array_register support_multiple_dimensions: true
    required_byte_size data_width

    input_pattern %r{(#{variable_name})(?::(#{number}))?}

    define_struct :index_entry, [:name, :value] do
      def initialize(name, value)
        self.name   = name
        self.value  = value && Integer(value)
      end

      def ==(other)
        return false unless name == other.name
        return true if [value, other.value].any?(&:nil?)
        value == other.value
      end
    end

    build do |cell|
      @indexes  = parse_indexes(cell.options.strip)
    end

    def parse_indexes(options)
      options.split(/[,\n]/).map do |entry|
        if pattern_match(entry)
          index_entry.new(captures[0], captures[1])
        else
          error "invalid value for index: #{options.inspect}"
        end
      end
    end

    validate do
      check_index_entries
      check_number_of_array_indexes
      check_array_index_values
      check_fixed_value_index_values
    end

    def check_index_entries
      indexes.each(&method(:check_index_entry))
    end

    def check_index_entry(entry)
      [
        :check_using_same_index_more_than_once,
        :check_using_non_existing_index,
        :check_using_own_bit_field_for_index,
        :check_using_arrayed_bit_field_for_index
      ].each do |checker|
        send(checker, entry)
      end
    end

    def check_using_same_index_more_than_once(entry)
      return if indexes.one? { |index| index.name == entry.name }
      error "not use the same index field more than once: #{entry.name}"
    end

    def check_using_non_existing_index(entry)
      return unless index_bit_fields[entry.name].nil?
      error "no such index field: #{entry.name}"
    end

    def check_using_own_bit_field_for_index(entry)
      return unless register.bit_fields.find_by(name: entry.name)
      error "not use own bit field for index field: #{entry.name}"
    end

    def check_using_arrayed_bit_field_for_index(entry)
      return unless index_bit_fields[entry.name].register.array?
      error "not use arrayed bit field for index field: #{entry.name}"
    end

    def check_number_of_array_indexes
      return if array_indexes.size == size_of_dimensions
      error "not match size of array dimensions and number of array indexes"
    end

    def check_array_index_values
      array_indexes.each_with_index do |entry, i|
        next if register.dimensions[i] <= (max_value(entry.name) + 1)
        error "array size(#{register.dimensions[i]}) is greater than " \
              "maximum value of #{entry.name}(#{max_value(entry.name)})"
      end
    end

    def check_fixed_value_index_values
      fixed_value_indexes.each_with_index do |entry, i|
        next if entry.value <= max_value(entry.name)
        error "index value(#{entry.value}) is greater thatn " \
              "maximum value of #{entry.name}(#{max_value(entry.name)})"
      end
    end

    def index_bit_fields
      @index_bit_fields ||= Hash.new do |h, name|
        h[name] = register_block.bit_fields.find_by(
          name: name, reserved?: false
        )
      end
    end

    def array_indexes
      indexes.select { |entry| entry.value.nil? }
    end

    def fixed_value_indexes
      indexes.select { |entry| entry.value }
    end

    def size_of_dimensions
      (register.array? && register.dimensions.size) || 0
    end

    def max_value(index_name)
      2**index_bit_fields[index_name].width - 1
    end
  end

  rtl do
    build do
      logic :register_block, :indirect_index,
            name:       "#{register.name}_indirect_index",
            width:      indirect_index_width,
            dimensions: dimensions
    end

    generate_code :module_item do |code|
      code << indirect_index_assignment << nl
      code << process_template
    end

    def indirect_index_fields
      @indirect_index_fields  ||= register.indexes.map do |i|
        register_block.bit_fields.find_by(name: i.name)
      end
    end

    def indirect_index_assignment
      assign(
        indirect_index[loop_variables],
        concat(indirect_index_fields.map(&:value))
      )
    end

    def indirect_index_width
      indirect_index_fields.sum(&:width)
    end

    def indirect_index_value
      concat(indirect_index_values)
    end

    def indirect_index_values
      variables = loop_variables
      register.indexes.map.with_index do |index, i|
        if index.value
          hex(index.value, indirect_index_fields[i].width)
        else
          variable  = variables.shift
          variable[indirect_index_fields[i].width - 1, 0]
        end
      end
    end
  end

  c_header do
    address_struct_member do
      variable_declaration(name: register.name, data_type: data_type)
    end
  end
end
