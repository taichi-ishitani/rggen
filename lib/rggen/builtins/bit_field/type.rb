list_item :bit_field, :type do
  register_map do
    item_base do
      define_helpers do
        def read_write
          @readable = true
          @writable = true
        end

        def read_only
          @readable = true
          @writable = false
        end

        def write_only
          @readable = false
          @writable = true
        end

        def reserved
          @readable = false
          @writable = false
        end

        def readable?
          @readable.nil? || @readable
        end

        def writable?
          @writable.nil? || @writable
        end

        def read_only?
          readable? && !writable?
        end

        def write_only?
          writable? && !readable?
        end

        def reserved?
          !(readable? || writable?)
        end

        attr_setter :required_width

        def full_width
          :full_width
        end

        def need_initial_value
          @need_initial_value = true
        end

        def need_initial_value?
          @need_initial_value || false
        end

        def use_reference(options = {})
          @use_reference      = true
          @reference_options  = options
        end

        attr_reader :reference_options

        def use_reference?
          @use_reference || false
        end

        def same_width
          :same_width
        end
      end

      field :type
      field :readable?  , forward_to_helper: true
      field :writable?  , forward_to_helper: true
      field :read_only? , forward_to_helper: true
      field :write_only?, forward_to_helper: true
      field :reserved?  , forward_to_helper: true

      class_delegator :full_width
      class_delegator :need_initial_value?
      class_delegator :use_reference?
      class_delegator :reference_options
      class_delegator :same_width

      build do |cell|
        @type = cell
      end

      validate do
        case
        when width_mismatch?
          error "#{required_width} bit(s) width required:" \
                " #{bit_field.width} bit(s)"
        when need_initial_value? && no_initial_value?
          error 'no initial value'
        when required_refercne_not_exist?
          error 'reference bit field required'
        when reference_width_mismatch?
          error "#{required_reference_width} bit(s) reference bit field" \
                " required: #{bit_field.reference.width}"
        end
      end

      def width_mismatch?
        return false if required_width.nil?
        if required_width.respond_to?(:include?)
          required_width.not.include?(bit_field.width)
        else
          bit_field.width != required_width
        end
      end

      def required_width
        width = self.class.required_width
        return nil if width.nil?
        return configuration.data_width if width == full_width
        width
      end

      def no_initial_value?
        !bit_field.initial_value?
      end

      def required_refercne_not_exist?
        return false unless use_reference?
        return false unless reference_options[:required]
        return false if bit_field.has_reference?
        true
      end

      def reference_width_mismatch?
        return false unless use_reference?
        return false unless bit_field.has_reference?
        bit_field.reference.width != required_reference_width
      end

      def required_reference_width
        return 1 unless reference_options[:width]
        return bit_field.width if reference_options[:width] == same_width
        reference_options[:width]
      end
    end

    factory do
      def select_target_item(cell)
        @target_items.fetch(cell.value) do
          error "unknown bit field type: #{cell.value}", cell
        end
      end

      def convert(cell)
        @target_items.keys.find(proc { cell }) do |type|
          type.to_sym.casecmp(cell.to_sym).zero?
        end
      end
    end
  end

  rtl do
    item_base do
      export :value

      delegate [
        :name, :width, :msb, :lsb, :type, :reserved?
      ] => :bit_field
      delegate [
        :dimensions, :index, :local_index, :loop_variables
      ] => :register

      available? { !bit_field.reserved? }

      build do
        interface :bit_field, :bit_field_sub_if,
                  type:       :rggen_bit_field_if,
                  name:       :bit_field_sub_if,
                  parameters: [width]
      end

      generate_pre_code :bit_field do |c|
        c << subroutine_call(:'`rggen_connect_bit_field_if', [
          register.bit_field_if, bit_field_sub_if, msb, lsb
        ]) << nl
      end

      def value
        register.register_if.value[msb, lsb]
      end
    end

    default_item do
    end

    factory do
      def select_target_item(_, bit_field)
        @target_items[bit_field.type]
      end
    end
  end

  ral do
    item_base do
      export :access
      export :model_name
      export :hdl_path

      define_helpers do
        attr_setter :access

        def model_name(&body)
          define_method(:model_name, &body)
        end

        def hdl_path(&body)
          define_method(:hdl_path, &body)
        end
      end

      def access
        string((self.class.access || bit_field.type).to_s.upcase)
      end

      def model_name
        :rggen_ral_field
      end

      def hdl_path
        "g_#{bit_field.name}.u_bit_field.value"
      end
    end

    default_item do
    end

    factory do
      def select_target_item(_, bit_field)
        @target_items[bit_field.type]
      end
    end
  end
end
