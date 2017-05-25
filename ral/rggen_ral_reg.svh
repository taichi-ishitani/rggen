`ifndef __RGGEN_RAL_REG_SVH__
`define __RGGEN_RAL_REG_SVH__
class rggen_ral_reg extends uvm_reg;
  protected int         indexes[$];
  protected uvm_object  cfg;
  protected string      hdl_path_scopes[string];

  extern function new(string name, int unsigned n_bits, int has_coverage);

  extern function void configure(
    uvm_object    cfg,
    uvm_reg_block blk_parent,
    uvm_reg_file  regfile_parent,
    int           indexes[$],
    string        hdl_path            = "",
    bit           single_hdl_variable = 0
  );
  extern virtual function void build();

  extern virtual function uvm_reg_frontdoor create_frontdoor();

  extern function void set_hdl_path_scope(string hdl_path_scope, string kind = "RTL");
  extern function void add_field_hdl_path(string name, int offset, int size, string kind = "RTL", string separalor = ".");

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
  string        hdl_path,
  bit           single_hdl_variable
);
  foreach (indexes[i]) begin
    this.indexes.push_back(indexes[i]);
  end
  set_cfg(cfg);
  if (single_hdl_variable) begin
    super.configure(blk_parent, regfile_parent, hdl_path);
  end
  else begin
    super.configure(blk_parent, regfile_parent);
    set_hdl_path_scope(hdl_path);
  end
endfunction

function void rggen_ral_reg::build();
  create_fields();
endfunction

function uvm_reg_frontdoor rggen_ral_reg::create_frontdoor();
  return null;
endfunction

function void rggen_ral_reg::set_hdl_path_scope(string hdl_path_scope, string kind);
  if (hdl_path_scope.len() > 0) begin
    hdl_path_scopes[kind] = hdl_path_scope;
  end
endfunction

function void rggen_ral_reg::add_field_hdl_path(string name, int offset, int size, string kind, string separalor);
  string  path;
  if (name.len() == 0) begin
    return;
  end
  if (hdl_path_scopes.exists(kind) && (hdl_path_scopes[kind].len() > 0)) begin
    path  = {hdl_path_scopes[kind], separalor, name};
  end
  else begin
    path  = name;
  end
  add_hdl_path_slice(path, offset, size, 0, kind);
endfunction

function void rggen_ral_reg::set_cfg(uvm_object cfg);
  this.cfg  = cfg;
endfunction

function void rggen_ral_reg::create_fields();
endfunction
`endif
