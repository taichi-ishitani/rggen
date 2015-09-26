RGen.list_item(:bit_field, :type) do
  register_map do
    item_base do
      class << self
        attr_reader :readable
        attr_reader :writable

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
      end

      field :type

      field :readable? do
        @readable
      end

      field :writable? do
        @writable
      end

      field :read_only? do
        @readable && !@writable
      end

      field :write_only? do
        !@readable && @writable
      end

      field :reserved? do
        !(@readable || @writable)
      end

      build do |cell|
        @type     = cell.to_sym.downcase
        @readable = object_class.readable.nil? || object_class.readable
        @writable = object_class.writable.nil? || object_class.writable
      end
    end

    factory do
      def select_target_item(cell)
        type  = cell.value.to_sym.downcase
        @target_items[type]
      end
    end
  end
end
