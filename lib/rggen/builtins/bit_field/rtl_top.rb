simple_item :bit_field, :rtl_top do
  rtl do
    generate_code :register do
      local_scope "g_#{bit_field.name}" do |s|
        s.signals bit_field.signal_declarations(:bit_field)
        s.without_generate_keyword
        s.body { |c| bit_field.generate_code(:bit_field, :top_down, c) }
      end
    end
  end
end
