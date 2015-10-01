RGen.value_item(:bit_field, :reference) do
  register_map do
    field :has_reference? do
      @reference.not.empty?
    end

    field :reference, need_validation:true do
      register_block.bit_fields.find do |bit_field|
        @reference == bit_field.name
      end if has_reference?
    end

    build do |cell|
      @reference  = cell.to_s
    end

    validate do
      case
      when @reference == bit_field.name
        error "self reference: #{@reference}"
      when has_reference? && no_reference?
        error "no such reference bit field: #{@reference}"
      end
    end

    def no_reference?
      register_block.bit_fields.none? do |bit_field|
        @reference == bit_field.name
      end
    end
  end
end
