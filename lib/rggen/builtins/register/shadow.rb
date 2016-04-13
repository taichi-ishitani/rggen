simple_item :register, :shadow do
  register_map do
    ShadowIndexEntry  = Struct.new(:name, :value) do
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

    field :shadow?
    field :shadow_indexes

    input_pattern %r{(#{variable_name})(?::(#{number}))?}

    build do |cell|
      @shadow_indexes = parse_shadow_indexes(cell)
      @shadow         = @shadow_indexes.not_nil?
    end

    validate do
      next unless shadow?
      check_using_shadow_register_only
      check_index_fields
      check_size_of_array_index_fields
      check_array_index_values
      check_specific_value_index_values
    end

    def parse_shadow_indexes(cell)
      return nil if cell.nil? || cell.empty?
      cell.split(/[,\n]/).map do |entry|
        if pattern_match(entry)
          ShadowIndexEntry.new(captures[0], captures[1])
        else
          error "invalid value for shadow index: #{cell.inspect}"
        end
      end
    end

    def check_using_shadow_register_only
      return unless register.multiple? && register.array?
      error 'not use real array and shadow register on the same register'
    end

    def check_index_fields
      shadow_indexes.each do |entry|
        case
        when use_same_index_field_more_than_once?(entry.name)
          error "not use the same index field more than once: #{entry.name}"
        when not_find_shadow_index_field?(entry)
          error "no such shadow index field: #{entry.name}"
        when use_own_bit_field?(entry)
          error 'own bit field is specified for shadow index field:' \
                " #{entry.name}"
        when use_arrayed_bit_field?(entry)
          error 'arrayed bit field is specified for shadow index field:' \
                " #{entry.name}"
        end
      end
    end

    def use_same_index_field_more_than_once?(name)
      shadow_indexes.count { |entry| entry.name == name } > 1
    end

    def not_find_shadow_index_field?(entry)
      shadow_index_bit_field[entry.name].nil?
    end

    def use_own_bit_field?(entry)
      register.bit_fields.map(&:name).include?(entry.name)
    end

    def use_arrayed_bit_field?(entry)
      shadow_index_bit_field[entry.name].register.array?
    end

    def check_size_of_array_index_fields
      return if size_of_dimensions == array_indexes.size
      error 'not match number of array dimensions and' \
            ' number of array index fields'
    end

    def check_array_index_values
      array_indexes.each_with_index do |entry, i|
        next if register.dimensions[i] <= (maximum_value(entry.name) + 1)
        error "exceeds maximum array size specified by #{entry.name}" \
              "(#{maximum_value(entry.name) + 1}): #{register.dimensions[i]}"
      end
    end

    def check_specific_value_index_values
      specific_value_indexes.each do |entry|
        next if entry.value <= maximum_value(entry.name)
        error "exceeds maximum value of #{entry.name}" \
              "(#{maximum_value(entry.name)}): #{entry.value}"
      end
    end

    def size_of_dimensions
      (register.array? && register.dimensions.size) || 0
    end

    def array_indexes
      shadow_indexes.select { |entry| entry.value.nil? }
    end

    def specific_value_indexes
      shadow_indexes.select { |entry| entry.value.not_nil? }
    end

    def maximum_value(index_name)
      2**shadow_index_bit_field[index_name].width - 1
    end

    def shadow_index_bit_field
      @shadow_index_bit_field ||= Hash.new do |hash, index_name|
        hash[index_name]  = register_block.bit_fields.find do |bit_field|
          bit_field.name == index_name && !bit_field.reserved?
        end
      end
    end
  end
end
