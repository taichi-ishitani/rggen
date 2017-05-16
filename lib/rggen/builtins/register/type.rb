list_item :register, :type do
  register_map do
    item_base do
      define_helpers do
        def readable?(&evaluator)
          @readability_evaluator  = evaluator
        end

        def writable?(&evaluator)
          @writability_evaluator  = evaluator
        end

        {
          read_write: [true , true ],
          read_only:  [true , false],
          write_only: [false, true ],
          reserved:   [false, false]
        }.each do |access_type, accessibility|
          define_method(access_type) do
            readable? { accessibility[0] }
            writable? { accessibility[1] }
          end
        end

        def need_options
          @need_options = true
        end

        def need_options?
          @need_options
        end

        def support_array_register(options = {})
          @support_array_register = true
          @array_options          = options
        end

        def support_array_register?
          @support_array_register
        end

        def array_options
          @array_options || {}
        end

        attr_setter :required_byte_size

        [:amount_of_registers, :data_width, :any_size].each do |width_type|
          define_method(width_type) { width_type }
        end

        def need_no_bit_fields
          @no_bit_fields  = true
        end

        def need_no_bit_fields?
          @no_bit_fields
        end
      end

      attr_class_reader :writability_evaluator
      attr_class_reader :readability_evaluator
      class_delegator   :need_options?
      class_delegator   :support_array_register?
      class_delegator   :array_options
      class_delegator   :required_byte_size
      class_delegator   :need_no_bit_fields?

      field :type

      field :type? do |other|
        other == type
      end

      field :readable? do
        next true if readability_evaluator.nil?
        instance_exec(&readability_evaluator)
      end

      field :writable? do
        next true if writability_evaluator.nil?
        instance_exec(&writability_evaluator)
      end

      field :read_only? do
        readable? && !writable?
      end

      field :write_only? do
        !readable? && writable?
      end

      field :reserved? do
        !(readable? || writable?)
      end

      build do |cell|
        @type = cell.type
        error 'no options are specified' if need_options? && cell.options.nil?
        register.need_no_children if need_no_bit_fields?
      end

      validate do
        check_array_register_usage
        check_array_demension
        check_byte_size
      end

      def check_array_register_usage
        return unless register.array?
        return if support_array_register?
        error 'array register is not allowed'
      end

      def check_array_demension
        return unless register.array?
        return if register.dimensions.size == 1
        return if array_options[:support_multiple_dimensions]
        error 'multiple dimensions array register is not allowed'
      end

      def check_byte_size
        return if required_byte_size == :any_size
        return if register.byte_size == required_byte_size_value
        error "byte size(#{register.byte_size}) is not matched with " \
              "required size(#{required_byte_size_value})"
      end

      def required_byte_size_value
        return configuration.byte_width if required_byte_size == :data_width
        register.count * configuration.byte_width
      end
    end

    default_item do
      readable? { register.bit_fields.any?(&:readable?) }
      writable? { register.bit_fields.any?(&:writable?) }
      support_array_register
      build { @type = :default }
    end

    factory do
      define_struct :cell_value, [:type, :options] do
        def empty?
          self.type.nil?
        end
      end

      def select_target_item(cell)
        @target_items.fetch(cell.value.type) do
          next if cell.value.type == :default
          error "unknown register type: #{cell.value.type}", cell
        end unless cell.empty?
      end

      def convert_cell_value(cell)
        cell.value  =
          if cell.empty?
            cell_value.new(nil, nil)
          else
            convert(cell.value)
          end
      end

      def convert(cell)
        [:default, *@target_items.keys].find_yield do |t|
          case cell
          when /\A#{t}(?::(.+))?\Z/im
            cell_value.new(t, Regexp.last_match.captures[0])
          end
        end || cell_value.new(cell, nil)
      end
    end
  end

  rtl do
    item_base do
      export :register_if

      delegate [:data_width, :byte_width] => :configuration
      delegate [:local_address_width] => :register_block
      delegate [:loop_variables, :local_index, :dimensions] => :register

      build do
        interface :register, :bit_field_if,
                  type:       :rggen_bit_field_if,
                  name:       :bit_field_if,
                  parameters: [data_width],
                  dimensions: [total_bit_fields] if total_bit_fields > 0
      end

      def register_if
        register_block.register_if[register.index]
      end

      private

      def actual_bit_fields
        @non_reserved_bit_fields  ||= register.bit_fields.reject(&:reserved?)
      end

      def total_bit_fields
        actual_bit_fields.size
      end

      def msb_list
        array(actual_bit_fields.map(&:msb))
      end

      def lsb_list
        array(actual_bit_fields.map(&:lsb))
      end

      def start_address
        address_code(register.start_address)
      end

      def end_address
        return address_code(register.end_address) unless register.array?
        address_code(
          register.start_address + byte_width - 1
        )
      end

      def address_code(address)
        base  = hex(address, local_address_width)
        if register.array? && register.multiple?
          increment_value = hex(byte_width, local_address_width)
          "#{base} + #{increment_value} * #{local_index}"
        else
          base
        end
      end
    end

    default_item do
      generate_code :register do
        process_template File.join(__dir__, 'types', 'default.erb')
      end
    end

    factory do
      def select_target_item(_, register)
        @target_items[register.type]
      end
    end
  end

  c_header do
    item_base do
      define_helpers do
        def address_struct_member(&body)
          define_method(:address_struct_member, &body)
        end
      end

      export :address_struct_member

      def data_type
        "rggen_uint#{configuration.data_width}"
      end
    end

    default_item do
      delegate [:name, :dimensions] => :register

      address_struct_member do
        variable_declaration(
          name: name, data_type: data_type, dimensions: dimensions
        )
      end
    end

    factory do
      def select_target_item(_, register)
        @target_items[register.type]
      end
    end
  end
end
