package sample_1_ral_pkg;
  import uvm_pkg::*;
  import rggen_ral_pkg::*;
  `include "uvm_macros.svh"
  `include "rggen_ral_macros.svh"
  class register_0_reg_model extends rggen_ral_reg;
    rand rggen_ral_field bit_field_0_0;
    rand rggen_ral_field bit_field_0_1;
    function new(string name = "register_0");
      super.new(name, 32, 0);
    endfunction
    function void create_fields();
      `rggen_ral_create_field_model(bit_field_0_0, "bit_field_0_0", 16, 16, "RW", 0, 16'h0000, 1)
      `rggen_ral_create_field_model(bit_field_0_1, "bit_field_0_1", 16, 0, "RO", 0, 16'h0000, 0)
    endfunction
  endclass
  class register_1_reg_model extends rggen_ral_reg;
    rand rggen_ral_field bit_field_1_0;
    function new(string name = "register_1");
      super.new(name, 32, 0);
    endfunction
    function void create_fields();
      `rggen_ral_create_field_model(bit_field_1_0, "bit_field_1_0", 32, 0, "RW", 0, 32'h00000000, 1)
    endfunction
  endclass
  class register_2_reg_model extends rggen_ral_reg;
    rand rggen_ral_field bit_field_2_0;
    rand rggen_ral_field bit_field_2_1;
    function new(string name = "register_2");
      super.new(name, 24, 0);
    endfunction
    function void create_fields();
      `rggen_ral_create_field_model(bit_field_2_0, "bit_field_2_0", 1, 16, "RO", 0, 1'h0, 0)
      `rggen_ral_create_field_model(bit_field_2_1, "bit_field_2_1", 1, 0, "RW", 0, 1'h0, 1)
    endfunction
  endclass
  class sample_1_block_model extends rggen_ral_block;
    rand register_0_reg_model register_0;
    rand register_1_reg_model register_1;
    rand register_2_reg_model register_2;
    function new(string name = "sample_1");
      super.new(name);
    endfunction
    function void create_sub_models();
      `rggen_ral_create_reg_model(register_0, "register_0", '{}, 7'h00, "RW", 0)
      `rggen_ral_create_reg_model(register_1, "register_1", '{}, 7'h04, "RW", 0)
      `rggen_ral_create_reg_model(register_2, "register_2", '{}, 7'h08, "RW", 0)
    endfunction
    function uvm_reg_map create_default_map();
      return create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN, 1);
    endfunction
  endclass
endpackage
