define_list_item :bit_field, :type, :foo do
  register_map do
  end
end

define_list_item :register_block, :host_if, :bar do
  rtl do
  end
end

enable :global        , [:data_width, :address_width]
enable :register_block, [:name, :base_address]
enable :register      , [:offset_address, :name, :array, :shadow, :accessibility, :uniquness_validator]
enable :bit_field     , [:bit_assignment, :name, :type, :initial_value, :reference]
enable :bit_field     , :type, [:rw, :ro, :foo, :reserved]
enable :register_block, [:module_declaration, :signal_declarations, :clock_reset, :host_if, :response_mux]
enable :register_block, :host_if, [:apb, :bar]
enable :register      , [:address_decoder, :read_data]
