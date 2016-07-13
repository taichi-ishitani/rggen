`ifndef __RGGEN_RAL_FIELD_RWL_RWE_SVH__
`define __RGGEN_RAL_FIELD_RWL_RWE_SVH__
class rggen_ral_field_rwl_rwe_cbs extends uvm_reg_cbs;
  local uvm_reg_field this_field;
  local bit           lock_mode;
  local string        mode_reg_name;
  local string        mode_field_name;
  local uvm_reg_field mode_field;

  extern function new(string name, uvm_reg_field this_field, bit lock_mode, string mode_reg_name, string mode_field_name);

  extern task pre_write(uvm_reg_item rw);
  extern function void post_predict(
    input uvm_reg_field   fld,
    input uvm_reg_data_t  previous,
    inout uvm_reg_data_t  value,
    input uvm_predict_e   kind,
    input uvm_path_e      path,
    input uvm_reg_map     map
  );

  extern local function void get_mode_field();
  extern local function bit not_wriable();
endclass

function rggen_ral_field_rwl_rwe_cbs::new(
  string        name,
  uvm_reg_field this_field,
  bit           lock_mode,
  string        mode_reg_name,
  string        mode_field_name
);
  super.new(name);
  this.this_field       = this_field;
  this.lock_mode        = lock_mode;
  this.mode_reg_name    = mode_reg_name;
  this.mode_field_name  = mode_field_name;
endfunction

task rggen_ral_field_rwl_rwe_cbs::pre_write(uvm_reg_item rw);
  if ((rw.kind == UVM_WRITE) && (rw.path == UVM_BACKDOOR) && not_wriable()) begin
    rw.value[0] = this_field.get_mirrored_value();
  end
endtask

function void rggen_ral_field_rwl_rwe_cbs::post_predict(
  input uvm_reg_field   fld,
  input uvm_reg_data_t  previous,
  inout uvm_reg_data_t  value,
  input uvm_predict_e   kind,
  input uvm_path_e      path,
  input uvm_reg_map     map
);
  if ((kind == UVM_PREDICT_WRITE) && not_wriable()) begin
    value = previous;
  end
endfunction

function void rggen_ral_field_rwl_rwe_cbs::get_mode_field();
  uvm_reg       parent_reg;
  uvm_reg_block parent_block;
  uvm_reg       mode_reg;

  parent_reg    = this_field.get_parent();
  parent_block  = parent_reg.get_parent();

  mode_reg  = parent_block.get_reg_by_name(mode_reg_name);
  if (mode_reg == null) begin
    `uvm_fatal("rggen_ral_field_rwl_rwe_cbs", $sformatf("Unable to locate the mode register: %s", mode_reg_name))
    return;
  end

  mode_field  = mode_reg.get_field_by_name(mode_field_name);
  if (mode_field == null) begin
    `uvm_fatal("rggen_ral_field_rwl_rwe_cbs", $sformatf("Unable to locate the mode field: %s", mode_field_name))
    return;
  end
endfunction

function bit rggen_ral_field_rwl_rwe_cbs::not_wriable();
  if (mode_field == null) begin
    get_mode_field();
  end
  if (lock_mode) begin
    return (mode_field.get() == 1) ? 1 : 0;
  end
  else begin
    return (mode_field.get() == 0) ? 1 : 0;
  end
endfunction

class rggen_ral_field_rwl_rwe extends rggen_ral_field;
  local static bit  rwl_defined = define_access("RWL");
  local static bit  rwe_defined = define_access("RWE");

  protected rggen_ral_field_rwl_rwe_cbs cbs;

  extern function new(string name, bit lock_mode, string mode_reg_name, string mode_field_name);

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
endclass

function rggen_ral_field_rwl_rwe::new(string name, bit lock_mode, string mode_reg_name, string mode_field_name);
  string  cbs_name;
  super.new(name);
  cbs_name  = (lock_mode) ? "rwl_cbs" : "rwe_cbs";
  cbs       = new(cbs_name, this, lock_mode, mode_reg_name, mode_field_name);
endfunction

function void rggen_ral_field_rwl_rwe::configure(
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
  super.configure(cfg, parent, size, lsb_pos, access, volatile, reset, has_reset, is_rand, individually_accessible);
  uvm_reg_field_cb::add(this, cbs);
endfunction

class rggen_ral_field_rwl #(
  string  MODE_REG_NAME   = "",
  string  MODE_FIELD_NAME = ""
) extends rggen_ral_field_rwl_rwe;
  extern function new(string name = "rggen_ral_field_rwl");
endclass

function rggen_ral_field_rwl::new(string name);
  super.new(name, 1, MODE_REG_NAME, MODE_FIELD_NAME);
endfunction

class rggen_ral_field_rwe #(
  string  MODE_REG_NAME   = "",
  string  MODE_FIELD_NAME = ""
) extends rggen_ral_field_rwl_rwe;
  extern function new(string name = "rggen_ral_field_rwe");
endclass

function rggen_ral_field_rwe::new(string name);
  super.new(name, 0, MODE_REG_NAME, MODE_FIELD_NAME);
endfunction
`endif
