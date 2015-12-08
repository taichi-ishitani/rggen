simple_item(:global, :data_width) do
  configuration do
    field :data_width, default: 32
    field :byte_width do
      data_width / 8
    end

    build do |width|
      begin
        @data_width = Integer(width)
      rescue
        error "invalid value for data width: #{width.inspect}"
      end

      unless @data_width >= 8 && @data_width.pow2?
        error "under 8/non-power of 2 data width is not allowed: #{@data_width}"
      end
    end
  end
end
