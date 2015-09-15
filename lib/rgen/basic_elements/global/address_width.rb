RGen.value_item(:global, :address_width) do
  configuration do
    field :address_width, default: 32

    build do |width|
      begin
        @address_width  = Integer(width)
      rescue
        error "invalid value for address width: #{width.inspect}"
      end

      unless @address_width.positive?
        error "zero/negative address width is not allowed: #{@address_width}"
      end
    end
  end
end
