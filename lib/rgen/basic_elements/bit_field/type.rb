RGen.list_item(:bit_field, :type) do
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

        def readable
          @readable.nil? || @readable
        end

        def writable
          @writable.nil? || @writable
        end
      end

      field :type
      field :readable?
      field :writable?
      field :read_only?
      field :write_only?
      field :reserved?

      build do |cell|
        @type       = cell.to_sym.downcase
        @readable   = object_class.readable
        @writable   = object_class.writable
        @read_only  =  @readable && !@writable
        @write_only = !@readable &&  @writable
        @reserved   = !@readable && !@writable
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
