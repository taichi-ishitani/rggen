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
enable :register      , [:offset_address, :name, :array, :type, :uniquness_validator]
enable :register      , :type, [:indirect, :external]
enable :bit_field     , [:bit_assignment, :name, :type, :initial_value, :reference]
enable :bit_field     , :type, [:rw, :ro, :w0c, :w1c, :w0s, :w1s, :rwl, :rwe, :foo, :reserved]
enable :register_block, [:top_module, :clock_reset, :host_if, :response_mux, :irq_controller]
enable :register_block, :host_if, [:apb, :bar]
enable :register      , [:address_decoder, :read_data, :bus_exporter]
enable :register_block, [:ral_package, :block_model, :constructor, :sub_model_creator, :default_map_creator]
enable :register      , [:reg_model, :constructor, :field_model_creator, :indirect_index_configurator, :sub_block_model]
enable :bit_field     , :field_model
