RGen.value_item(:register, :accessibility) do
  register_map do
    field :readable? do
      register.bit_fields.any?(&:readable?)
    end

    field :writable? do
      register.bit_fields.any?(&:writable?)
    end

    field :read_only? do
      readable? && !writable?
    end

    field :write_only? do
      writable? && !readable?
    end

    field :reserved? do
      register.bit_fields.all?(&:reserved?)
    end
  end
end
