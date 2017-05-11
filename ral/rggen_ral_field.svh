`ifndef __RGGEN_RAL_FIELD_SVH__
`define __RGGEN_RAL_FIELD_SVH__
class rggen_ral_field extends uvm_reg_field;
  protected uvm_object  cfg;

  extern function new(string name = "rggen_ral_field");

  extern function void configure(
    uvm_object      cfg,
    uvm_reg         parent,
    int unsigned    size,
    int unsigned    lsb_pos,
    string          access,
    bit             volatile,
    uvm_reg_data_t  reset,
    bit             has_reset,
    bit             is_rand,
    bit             individually_accessible
  );

  extern protected virtual function void set_cfg(uvm_object cfg);
endclass

function rggen_ral_field::new(string name);
  super.new(name);
endfunction

function void rggen_ral_field::configure(
  uvm_object      cfg,
  uvm_reg         parent,
  int unsigned    size,
  int unsigned    lsb_pos,
  string          access,
  bit             volatile,
  uvm_reg_data_t  reset,
  bit             has_reset,
  bit             is_rand,
  bit             individually_accessible
);
  set_cfg(cfg);
  super.configure(parent, size, lsb_pos, access, volatile, reset, has_reset, is_rand, individually_accessible);
endfunction

function void rggen_ral_field::set_cfg(uvm_object cfg);
  this.cfg  = cfg;
endfunction
`endif
