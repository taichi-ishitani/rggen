enable :global        , [:data_width, :address_width]
enable :register_block, [:name, :byte_size]
enable :register      , [:offset_address, :name, :array, :type, :uniquness_validator]
enable :register      , :type, [:indirect, :external]
enable :bit_field     , [:bit_assignment, :name, :type, :initial_value, :reference]
enable :bit_field     , :type, [:rw, :ro, :w0c, :w1c, :w0s, :w1s, :rwl, :rwe, :reserved]
enable :register_block, [:rtl_top, :clock_reset, :host_if]
enable :register_block, :host_if, [:apb, :axi4lite]
enable :register      , :rtl_top
enable :bit_field     , :rtl_top
enable :register_block, [:ral_package, :block_model, :constructor, :sub_model_creator, :default_map_creator]
enable :register      , [:reg_model, :constructor, :field_model_creator, :indirect_index_configurator, :sub_block_model]
enable :bit_field     , :field_model
enable :register_block, [:c_header_file, :address_struct]
