`ifndef __RGEN_RAL_BLOCK_SVH__
`define __RGEN_RAL_BLOCK_SVH__
class rgen_ral_block extends uvm_reg_block;
  protected uvm_object  cfg;

  extern function new(string name= "rgen_ral_block", int has_coverage = UVM_NO_COVERAGE);

  extern function void configure(uvm_object cfg, uvm_reg_block parent = null, string hdl_path = "");

  extern virtual function uvm_reg_map create_map(
    string            name,
    uvm_reg_addr_t    base_addr,
    int unsigned      n_bytes,
    uvm_endianness_e  endian,
    bit               byte_addressing = 1
  );
  extern virtual function void lock_model();

  extern protected virtual function void set_cfg(uvm_object cfg);
  extern protected virtual function uvm_reg_map create_default_map();
  extern protected virtual function void create_blocks();
  extern protected virtual function void create_registers();
endclass

function rgen_ral_block::new(string name, int has_coverage);
  super.new(name, has_coverage);
endfunction

function void rgen_ral_block::configure(uvm_object cfg, uvm_reg_block parent, string hdl_path);
  set_cfg(cfg);
  super.configure(parent, hdl_path);
  if (default_map == null) begin
    default_map = create_default_map();
  end
  create_blocks();
  create_registers();
endfunction

function uvm_reg_map rgen_ral_block::create_map(
  string            name,
  uvm_reg_addr_t    base_addr,
  int unsigned      n_bytes,
  uvm_endianness_e  endian,
  bit               byte_addressing
);
  uvm_factory f = uvm_factory::get();
  f.set_inst_override_by_type(uvm_reg_map::get_type(), rgen_ral_map::get_type(), {get_full_name(), ".", name});
  return super.create_map(name, base_addr, n_bytes, endian, byte_addressing);
endfunction

function void rgen_ral_block::lock_model();
  uvm_reg_block parent_block  = get_parent();

  if (is_locked()) begin
    return;
  end

  super.lock_model();

  if (parent_block == null) begin
    uvm_reg_map maps[$];
    get_maps(maps);
    foreach (maps[i]) begin
      rgen_ral_map  rgen_map;
      if ($cast(rgen_map, maps[i])) begin
        rgen_map.Xinit_shadow_reg_address_mapX();
      end
    end
  end
endfunction

function void rgen_ral_block::set_cfg(uvm_object cfg);
  this.cfg  = cfg;
endfunction

function uvm_reg_map rgen_ral_block::create_default_map();
endfunction

function void rgen_ral_block::create_blocks();
endfunction

function void rgen_ral_block::create_registers();
endfunction
`endif
