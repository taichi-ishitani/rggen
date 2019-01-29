simple_item :global, :array_port_format do
  configuration do
    field :array_port_format, default: :unpacked

    input_pattern /(unpacked|vectored)/i

    build do |value|
      pattern_matched? || (
        error 'invalid array port format; ' \
              "should be 'unpacked' or 'vectored': #{value.inspect}"
      )
      @array_port_format  = captures.first.downcase.to_sym
    end
  end
end
