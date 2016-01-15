simple_item :register, :uniqueness_validator do
  register_map do
    validate do
      previous_registers.each do |previous_register|
        validate_uniqueness(previous_register)
      end
    end

    def previous_registers
      register_block.registers.take_while { |r| !r.equal?(register) }
    end

    def validate_uniqueness(previous_register)
      case
      when overlap_offset_address?(previous_register)
        error 'offset address is not unique', error_position(:start_address)
      when overlap_shadow_indexes?(previous_register)
        error 'shadow indexes is not unique', error_position(:shadow_indexes)
      end
    end

    def overlap_offset_address?(previous_register)
      return false if [previous_register, register].all?(&:shadow?)
      overlap_address_range?(register, previous_register)
    end

    def overlap_address_range?(lhs, rhs)
      lhs_range = lhs.start_address..lhs.end_address
      rhs_range = rhs.start_address..rhs.end_address
      lhs_range.overlap?(rhs_range)
    end

    def overlap_shadow_indexes?(previous_register)
      return false unless overlap_address_range?(register, previous_register)
      return true  unless unique_shadw_indexes?(register, previous_register)
      return true  unless unique_shadw_indexes?(previous_register, register)
      false
    end

    def unique_shadw_indexes?(lhs, rhs)
      lhs.shadow_indexes.any?(&rhs.shadow_indexes.method(:exclude?))
    end

    def error_position(field)
      register.items.find { |i| i.fields.include?(field) }.position
    end
  end
end
