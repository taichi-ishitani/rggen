`ifndef __RGGEN_RAL_REG_SVH__
`define __RGGEN_RAL_REG_SVH__
class rggen_ral_reg extends uvm_reg;
  protected int         indexes[$];
  protected uvm_object  cfg;

  extern function new(string name, int unsigned n_bits, int has_coverage);

  extern function void configure(
    uvm_object    cfg,
    uvm_reg_block blk_parent,
    uvm_reg_file  regfile_parent,
    int           indexes[$],
    string        hdl_path = ""
  );
  extern virtual function void build();

  extern virtual function uvm_reg_frontdoor create_frontdoor();

  extern protected virtual function void set_cfg(uvm_object cfg);
  extern protected virtual function void create_fields();
endclass

function rggen_ral_reg::new(string name, int unsigned n_bits, int has_coverage);
  super.new(name, n_bits, has_coverage);
endfunction

function void rggen_ral_reg::configure(
  uvm_object    cfg,
  uvm_reg_block blk_parent,
  uvm_reg_file  regfile_parent,
  int           indexes[$],
  string        hdl_path
);
  foreach (indexes[i]) begin
    this.indexes.push_back(indexes[i]);
  end
  set_cfg(cfg);
  super.configure(blk_parent, regfile_parent, hdl_path);
endfunction

function void rggen_ral_reg::build();
  create_fields();
endfunction

function uvm_reg_frontdoor rggen_ral_reg::create_frontdoor();
  return null;
endfunction

function void rggen_ral_reg::set_cfg(uvm_object cfg);
  this.cfg  = cfg;
endfunction

function void rggen_ral_reg::create_fields();
endfunction
`endif
