package sample_0_ral_pkg;
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
      `rggen_ral_create_field_model(bit_field_0_0, "bit_field_0_0", 16, 16, "RW", 0, 16'h0000, 1, "u_bit_field_0_0.value")
      `rggen_ral_create_field_model(bit_field_0_1, "bit_field_0_1", 16, 0, "RW", 0, 16'h0000, 1, "u_bit_field_0_1.value")
    endfunction
  endclass
  class register_1_reg_model extends rggen_ral_reg;
    rand rggen_ral_field bit_field_1_0;
    function new(string name = "register_1");
      super.new(name, 32, 0);
    endfunction
    function void create_fields();
      `rggen_ral_create_field_model(bit_field_1_0, "bit_field_1_0", 32, 0, "RW", 0, 32'h00000000, 1, "u_bit_field_1_0.value")
    endfunction
  endclass
  class register_2_reg_model extends rggen_ral_reg;
    rand rggen_ral_field bit_field_2_0;
    rand rggen_ral_field bit_field_2_1;
    function new(string name = "register_2");
      super.new(name, 24, 0);
    endfunction
    function void create_fields();
      `rggen_ral_create_field_model(bit_field_2_0, "bit_field_2_0", 1, 16, "RO", 0, 1'h0, 0, "u_bit_field_2_0.i_value")
      `rggen_ral_create_field_model(bit_field_2_1, "bit_field_2_1", 1, 0, "RW", 0, 1'h0, 1, "u_bit_field_2_1.value")
    endfunction
  endclass
  class register_3_reg_model extends rggen_ral_reg;
    rand rggen_ral_field bit_field_3_0;
    function new(string name = "register_3");
      super.new(name, 32, 0);
    endfunction
    function void create_fields();
      `rggen_ral_create_field_model(bit_field_3_0, "bit_field_3_0", 32, 0, "RO", 0, 32'h00000000, 0, "u_bit_field_3_0.i_value")
    endfunction
  endclass
  class register_4_reg_model extends rggen_ral_reg;
    rand rggen_ral_field bit_field_4_0;
    rand rggen_ral_field bit_field_4_1;
    function new(string name = "register_4");
      super.new(name, 32, 0);
    endfunction
    function void create_fields();
      `rggen_ral_create_field_model(bit_field_4_0, "bit_field_4_0", 16, 16, "RO", 0, 16'h0000, 0, "u_bit_field_4_0.i_value")
      `rggen_ral_create_field_model(bit_field_4_1, "bit_field_4_1", 16, 0, "RW", 0, 16'h0000, 1, "u_bit_field_4_1.value")
    endfunction
  endclass
  class register_5_reg_model extends rggen_ral_indirect_reg;
    rand rggen_ral_field bit_field_5_0;
    rand rggen_ral_field bit_field_5_1;
    function new(string name = "register_5");
      super.new(name, 32, 0);
    endfunction
    function void create_fields();
      `rggen_ral_create_field_model(bit_field_5_0, "bit_field_5_0", 16, 16, "RO", 0, 16'h0000, 0, "u_bit_field_5_0.i_value")
      `rggen_ral_create_field_model(bit_field_5_1, "bit_field_5_1", 16, 0, "RW", 0, 16'h0000, 1, "u_bit_field_5_1.value")
    endfunction
    function void configure_indirect_indexes();
      set_indirect_index("register_2", "bit_field_2_1", 1);
      set_indirect_index("register_0", "bit_field_0_0", indexes[0]);
      set_indirect_index("register_0", "bit_field_0_1", indexes[1]);
    endfunction
  endclass
  class register_6_reg_model extends rggen_ral_reg;
    rand rggen_ral_field bit_field_6_0;
    rand rggen_ral_field bit_field_6_1;
    function new(string name = "register_6");
      super.new(name, 16, 0);
    endfunction
    function void create_fields();
      `rggen_ral_create_field_model(bit_field_6_0, "bit_field_6_0", 1, 8, "W0C", 0, 1'h0, 1, "u_bit_field_6_0.value")
      `rggen_ral_create_field_model(bit_field_6_1, "bit_field_6_1", 1, 0, "W1C", 0, 1'h0, 1, "u_bit_field_6_1.value")
    endfunction
  endclass
  class register_7_reg_model extends rggen_ral_reg;
    rand rggen_ral_field bit_field_7_0;
    rand rggen_ral_field bit_field_7_1;
    function new(string name = "register_7");
      super.new(name, 16, 0);
    endfunction
    function void create_fields();
      `rggen_ral_create_field_model(bit_field_7_0, "bit_field_7_0", 1, 8, "W0S", 0, 1'h0, 1, "u_bit_field_7_0.value")
      `rggen_ral_create_field_model(bit_field_7_1, "bit_field_7_1", 1, 0, "W1S", 0, 1'h0, 1, "u_bit_field_7_1.value")
    endfunction
  endclass
  class register_8_reg_model extends rggen_ral_reg;
    rand rggen_ral_field_rwl#("register_2", "bit_field_2_1") bit_field_8_0;
    rand rggen_ral_field_rwe#("register_2", "bit_field_2_1") bit_field_8_1;
    function new(string name = "register_8");
      super.new(name, 32, 0);
    endfunction
    function void create_fields();
      `rggen_ral_create_field_model(bit_field_8_0, "bit_field_8_0", 16, 16, "RWL", 0, 16'h0000, 1, "u_bit_field_8_0.value")
      `rggen_ral_create_field_model(bit_field_8_1, "bit_field_8_1", 16, 0, "RWE", 0, 16'h0000, 1, "u_bit_field_8_1.value")
    endfunction
  endclass
  class sample_0_block_model#(
    type REGISTER_9 = rggen_ral_block
  ) extends rggen_ral_block;
    rand register_0_reg_model register_0;
    rand register_1_reg_model register_1;
    rand register_2_reg_model register_2;
    rand register_3_reg_model register_3;
    rand register_4_reg_model register_4[4];
    rand register_5_reg_model register_5[2][4];
    rand register_6_reg_model register_6;
    rand register_7_reg_model register_7;
    rand register_8_reg_model register_8;
    rand REGISTER_9 register_9;
    function new(string name = "sample_0");
      super.new(name);
    endfunction
    function void create_sub_models();
      `rggen_ral_create_reg_model(register_0, "register_0", '{}, 8'h00, "RW", 0, "")
      `rggen_ral_create_reg_model(register_1, "register_1", '{}, 8'h04, "RW", 0, "")
      `rggen_ral_create_reg_model(register_2, "register_2", '{}, 8'h08, "RW", 0, "")
      `rggen_ral_create_reg_model(register_3, "register_3", '{}, 8'h0c, "RO", 0, "")
      foreach (register_4[i]) begin
        `rggen_ral_create_reg_model(register_4[i], $sformatf("register_4[%0d]", i), '{i}, 8'h10 + 4 * i, "RW", 0, $sformatf("g_register_4.g[%0d]", i))
      end
      foreach (register_5[i, j]) begin
        `rggen_ral_create_reg_model(register_5[i][j], $sformatf("register_5[%0d][%0d]", i, j), '{i, j}, 8'h20, "RW", 1, $sformatf("g_register_5.g[%0d].g[%0d]", i, j))
      end
      `rggen_ral_create_reg_model(register_6, "register_6", '{}, 8'h24, "RW", 0, "")
      `rggen_ral_create_reg_model(register_7, "register_7", '{}, 8'h28, "RW", 0, "")
      `rggen_ral_create_reg_model(register_8, "register_8", '{}, 8'h2c, "RW", 0, "")
      `rggen_ral_create_block_model(register_9, "register_9", 8'h80)
    endfunction
    function uvm_reg_map create_default_map();
      return create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN, 1);
    endfunction
  endclass
endpackage
