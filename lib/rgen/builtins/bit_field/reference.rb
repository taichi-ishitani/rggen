RGen.simple_item(:bit_field, :reference) do
  register_map do
    field :reference, need_validation:true, :forward_to=>:find_reference
    field :has_reference? do
      @reference.not.empty?
    end

    build do |cell|
      @reference  = cell.to_s
    end

    validate do
      case
      when @reference == bit_field.name
        error "self reference: #{@reference}"
      when not_find_reference?
        error "no such reference bit field: #{@reference}"
      when refer_reserved_bit_field?
        error "reserved bit field is refered: #{@reference}"
      end
    end

    def not_find_reference?
      return false unless has_reference?
      find_reference.nil?
    end

    def refer_reserved_bit_field?
      return false unless has_reference?
      find_reference.reserved?
    end

    private

    def find_reference
      return nil unless has_reference?
      @found_reference  ||= register_block.bit_fields.find do |bit_field|
        bit_field.name == @reference
      end
    end
  end
end
