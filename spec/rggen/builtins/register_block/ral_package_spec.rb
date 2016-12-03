require_relative '../spec_helper'

describe "register_block/ral_package" do
  include_context 'configuration common'
  include_context 'register_map common'
  include_context 'ral common'

  before(:all) do
    enable :global        , [:data_width, :address_width]
    enable :register_block, [:name, :byte_size]
    enable :register      , [:name, :offset_address, :array, :type]
    enable :register      , :type, [:external, :indirect]
    enable :bit_field     , [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field     , :type, [:rw, :ro, :w0c, :w1c, :w0s, :w1s, :wo]
    enable :bit_field     , :field_model
    enable :register      , [:reg_model, :constructor, :field_model_creator, :shadow_index_configurator, :sub_block_model]
    enable :register_block, [:block_model, :constructor, :sub_model_creator, :default_map_creator]
    enable :register_block, :ral_package

    configuration = create_configuration
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil         ,"block_0"                                                                                                                                      ],
        [nil, nil         , 256                                                                                                                                           ],
        [                                                                                                                                                                 ],
        [                                                                                                                                                                 ],
        [nil, "register_0", "0x00"     , nil     , nil                                                                       , "bit_field_0_0", "[31:24]", "rw" , 0  , nil],
        [nil, nil         , nil        , nil     , nil                                                                       , "bit_field_0_1", "[23:16]", "rw" , 1  , nil],
        [nil, nil         , nil        , nil     , nil                                                                       , "bit_field_0_2", "[15: 8]", "ro" , 2  , nil],
        [nil, nil         , nil        , nil     , nil                                                                       , "bit_field_0_3", "[ 7: 0]", "ro" , nil, nil],
        [nil, "register_1", "0x04"     , "[2, 4]", "indirect: bit_field_0_0, bit_field_0_1:1, bit_field_0_2, bit_field_0_3:3", "bit_field_1_0", "[15:12]", "ro" , nil, nil],
        [nil, nil         , nil        , nil     , nil                                                                       , "bit_field_1_1", "[11: 8]", "ro" , 3  , nil],
        [nil, nil         , nil        , nil     , nil                                                                       , "bit_field_1_2", "[ 7: 4]", "rw" , 4  , nil],
        [nil, nil         , nil        , nil     , nil                                                                       , "bit_field_1_3", "[ 3: 0]", "rw" , 5  , nil],
        [nil, "register_2", "0x08"     , nil     , nil                                                                       , "bit_field_2_0", "[8]"    , "w0c", 0  , nil],
        [nil, nil         , nil        , nil     , nil                                                                       , "bit_field_2_1", "[0]"    , "w1c", 0  , nil],
        [nil, "register_3", "0x0C"     , nil     , nil                                                                       , "bit_field_3_0", "[8]"    , "w0s", 0  , nil],
        [nil, nil         , nil        , nil     , nil                                                                       , "bit_field_3_1", "[0]"    , "w1s", 0  , nil],
        [nil, "register_4", "0x10-0x1F", nil     , :external                                                                 , nil            , nil      , nil  , nil, nil]
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

  describe "#write_file" do
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
      `rggen_ral_create_field_model(bit_field_0_0, "bit_field_0_0", 8, 24, "RW", 0, 8'h00, 1, "u_bit_field_0_0.value")
      `rggen_ral_create_field_model(bit_field_0_1, "bit_field_0_1", 8, 16, "RW", 0, 8'h01, 1, "u_bit_field_0_1.value")
      `rggen_ral_create_field_model(bit_field_0_2, "bit_field_0_2", 8, 8, "RO", 0, 8'h02, 1, "u_bit_field_0_2.i_value")
      `rggen_ral_create_field_model(bit_field_0_3, "bit_field_0_3", 8, 0, "RO", 0, 8'h00, 0, "u_bit_field_0_3.i_value")
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
      `rggen_ral_create_field_model(bit_field_1_0, "bit_field_1_0", 4, 12, "RO", 0, 4'h0, 0, "u_bit_field_1_0.i_value")
      `rggen_ral_create_field_model(bit_field_1_1, "bit_field_1_1", 4, 8, "RO", 0, 4'h3, 1, "u_bit_field_1_1.i_value")
      `rggen_ral_create_field_model(bit_field_1_2, "bit_field_1_2", 4, 4, "RW", 0, 4'h4, 1, "u_bit_field_1_2.value")
      `rggen_ral_create_field_model(bit_field_1_3, "bit_field_1_3", 4, 0, "RW", 0, 4'h5, 1, "u_bit_field_1_3.value")
    endfunction
    function void configure_shadow_indexes();
      set_shadow_index("register_0", "bit_field_0_0", indexes[0]);
      set_shadow_index("register_0", "bit_field_0_1", 1);
      set_shadow_index("register_0", "bit_field_0_2", indexes[1]);
      set_shadow_index("register_0", "bit_field_0_3", 3);
    endfunction
  endclass
  class register_2_reg_model extends rggen_ral_reg;
    rand rggen_ral_field bit_field_2_0;
    rand rggen_ral_field bit_field_2_1;
    function new(string name = "register_2");
      super.new(name, 16, 0);
    endfunction
    function void create_fields();
      `rggen_ral_create_field_model(bit_field_2_0, "bit_field_2_0", 1, 8, "W0C", 0, 1'h0, 1, "u_bit_field_2_0.value")
      `rggen_ral_create_field_model(bit_field_2_1, "bit_field_2_1", 1, 0, "W1C", 0, 1'h0, 1, "u_bit_field_2_1.value")
    endfunction
  endclass
  class register_3_reg_model extends rggen_ral_reg;
    rand rggen_ral_field bit_field_3_0;
    rand rggen_ral_field bit_field_3_1;
    function new(string name = "register_3");
      super.new(name, 16, 0);
    endfunction
    function void create_fields();
      `rggen_ral_create_field_model(bit_field_3_0, "bit_field_3_0", 1, 8, "W0S", 0, 1'h0, 1, "u_bit_field_3_0.value")
      `rggen_ral_create_field_model(bit_field_3_1, "bit_field_3_1", 1, 0, "W1S", 0, 1'h0, 1, "u_bit_field_3_1.value")
    endfunction
  endclass
  class block_0_block_model#(
    type REGISTER_4 = rggen_ral_block
  ) extends rggen_ral_block;
    rand register_0_reg_model register_0;
    rand register_1_reg_model register_1[2][4];
    rand register_2_reg_model register_2;
    rand register_3_reg_model register_3;
    rand REGISTER_4 register_4;
    function new(string name = "block_0");
      super.new(name);
    endfunction
    function void create_sub_models();
      `rggen_ral_create_reg_model(register_0, "register_0", '{}, 8'h00, "RW", 0, "")
      foreach (register_1[i, j]) begin
        `rggen_ral_create_reg_model(register_1[i][j], $sformatf("register_1[%0d][%0d]", i, j), '{i, j}, 8'h04, "RW", 1, $sformatf("g_register_1.g[%0d].g[%0d]", i, j))
      end
      `rggen_ral_create_reg_model(register_2, "register_2", '{}, 8'h08, "RW", 0, "")
      `rggen_ral_create_reg_model(register_3, "register_3", '{}, 8'h0c, "RW", 0, "")
      `rggen_ral_create_block_model(register_4, "register_4", 8'h10)
    endfunction
    function uvm_reg_map create_default_map();
      return create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN, 1);
    endfunction
  endclass
endpackage
CODE
    end

    it "レジスタモジュールのRALパッケージを書き出す" do
      expect { ral.write_file('.') }.to write_binary_file("./block_0_ral_pkg.sv", expected_code)
    end
  end
end
