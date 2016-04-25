require_relative '../spec_helper'

describe "register_block/ral_package" do
  include_context 'configuration common'
  include_context 'register_map common'
  include_context 'ral common'

  before(:all) do
    enable :global        , [:data_width, :address_width]
    enable :register_block, [:name, :byte_size]
    enable :register      , [:name, :offset_address, :array, :shadow, :accessibility]
    enable :bit_field     , [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field     , :type, [:rw, :ro, :wo]
    enable :bit_field     , :field_model
    enable :register      , [:reg_model, :constructor, :field_model_creator, :shadow_index_configurator]
    enable :register_block, [:block_model, :constructor, :reg_model_creator, :default_map_creator]
    enable :register_block, :ral_package

    configuration = create_configuration
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil         ,"block_0"                                                                                                                      ],
        [nil, nil         , 256                                                                                                                           ],
        [                                                                                                                                                 ],
        [                                                                                                                                                 ],
        [nil, "register_0", "0x00", nil     , nil                                                             , "bit_field_0_0", "[31:24]", "rw", 0  , nil],
        [nil, nil         , nil   , nil     , nil                                                             , "bit_field_0_1", "[23:16]", "rw", 1  , nil],
        [nil, nil         , nil   , nil     , nil                                                             , "bit_field_0_2", "[15: 8]", "ro", 2  , nil],
        [nil, nil         , nil   , nil     , nil                                                             , "bit_field_0_3", "[ 7: 0]", "ro", nil, nil],
        [nil, "register_1", "0x04", "[2, 4]", "bit_field_0_0, bit_field_0_1:1, bit_field_0_2, bit_field_0_3:3", "bit_field_1_0", "[15:12]", "ro", nil, nil],
        [nil, nil         , nil   , nil     , nil                                                             , "bit_field_1_1", "[11: 8]", "ro", 3  , nil],
        [nil, nil         , nil   , nil     , nil                                                             , "bit_field_1_2", "[ 7: 4]", "rw", 4  , nil],
        [nil, nil         , nil   , nil     , nil                                                             , "bit_field_1_3", "[ 3: 0]", "rw", 5  , nil]
      ]
    )
    @ral  = build_ral_factory.create(configuration, register_map).register_blocks[0]
  end

  after(:all) do
    clear_enabled_items
  end

  let(:ral) do
    @ral
  end

  after(:all) do
    clear_enabled_items
  end

  let(:ral) do
    @ral
  end

  describe "#write_file" do
    before do
      expect(File).to receive(:write).with("./block_0_ral_pkg.sv", expected_code, nil, binmode: true)
    end

    let(:expected_code) do
      <<'CODE'
package block_0_ral_pkg;
  import uvm_pkg::*;
  import rggen_ral_pkg::*;
  `include "uvm_macros.svh"
  `include "rggen_ral_macros.svh"
  class register_0_reg_model extends rggen_ral_reg;
    rand rggen_ral_field bit_field_0_0;
    rand rggen_ral_field bit_field_0_1;
    rand rggen_ral_field bit_field_0_2;
    rand rggen_ral_field bit_field_0_3;
    function new(string name = "register_0");
      super.new(name, 32, 0);
    endfunction
    function void create_fields();
      `rggen_ral_create_field_model(bit_field_0_0, "bit_field_0_0", 8, 24, "RW", 0, 8'h00, 1)
      `rggen_ral_create_field_model(bit_field_0_1, "bit_field_0_1", 8, 16, "RW", 0, 8'h01, 1)
      `rggen_ral_create_field_model(bit_field_0_2, "bit_field_0_2", 8, 8, "RO", 0, 8'h02, 1)
      `rggen_ral_create_field_model(bit_field_0_3, "bit_field_0_3", 8, 0, "RO", 0, 8'h00, 0)
    endfunction
  endclass
  class register_1_reg_model extends rggen_ral_shadow_reg;
    rand rggen_ral_field bit_field_1_0;
    rand rggen_ral_field bit_field_1_1;
    rand rggen_ral_field bit_field_1_2;
    rand rggen_ral_field bit_field_1_3;
    function new(string name = "register_1");
      super.new(name, 16, 0);
    endfunction
    function void create_fields();
      `rggen_ral_create_field_model(bit_field_1_0, "bit_field_1_0", 4, 12, "RO", 0, 4'h0, 0)
      `rggen_ral_create_field_model(bit_field_1_1, "bit_field_1_1", 4, 8, "RO", 0, 4'h3, 1)
      `rggen_ral_create_field_model(bit_field_1_2, "bit_field_1_2", 4, 4, "RW", 0, 4'h4, 1)
      `rggen_ral_create_field_model(bit_field_1_3, "bit_field_1_3", 4, 0, "RW", 0, 4'h5, 1)
    endfunction
    function void configure_shadow_indexes();
      set_shadow_index("register_0", "bit_field_0_0", indexes[0]);
      set_shadow_index("register_0", "bit_field_0_1", 1);
      set_shadow_index("register_0", "bit_field_0_2", indexes[1]);
      set_shadow_index("register_0", "bit_field_0_3", 3);
    endfunction
  endclass
  class block_0_block_model extends rggen_ral_block;
    rand register_0_reg_model register_0;
    rand register_1_reg_model register_1[2][4];
    function new(string name = "block_0");
      super.new(name);
    endfunction
    function void create_registers();
      `rggen_ral_create_reg_model(register_0, "register_0", '{}, 8'h00, "RW", 0)
      foreach (register_1[i, j]) begin
        `rggen_ral_create_reg_model(register_1[i][j], "register_1", '{i, j}, 8'h04, "RW", 1)
      end
    endfunction
    function uvm_reg_map create_default_map();
      return create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN, 1);
    endfunction
  endclass
endpackage
CODE
    end

    it "レジスタモジュールのRALパッケージを書き出す" do
      ral.write_file('.')
    end
  end
end
