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

        def need_no_bit_fields
          @no_bit_fields  = true
        end
      end

      attr_class_reader :writability_evaluator
      attr_class_reader :readability_evaluator
      attr_class_reader :no_bit_fields

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
        register.need_no_children if no_bit_fields
      end
    end

    default_item do
      readable? { register.bit_fields.any?(&:readable?) }
      writable? { register.bit_fields.any?(&:writable?) }
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
          when /\A#{t}(?::(.+))?\Z/i
            cell_value.new(t, Regexp.last_match.captures[0])
          end
        end || cell_value.new(cell, nil)
      end
    end
  end
end
