simple_item :global, :unfold_sv_interface_port do
  configuration do
    field :unfold_sv_interface_port?, default: false

    build do |value|
      @unfold_sv_interface_port =
        case value
        when true, false
          value
        when /\Atrue|on|yes\z/i
          true
        when /\Afalse|nil|off|no\z/i
          false
        else
          message =
            'non boolean value; should be true/false/nil/on/off/yes/no: ' \
            "#{value.inspect}"
          error message
        end
    end
  end
end
