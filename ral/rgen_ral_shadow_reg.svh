`ifndef __RGEN_RAL_SHADOW_REG_SVH__
`define __RGEN_RAL_SHADOW_REG_SVH__
typedef class rgen_ral_shadow_reg_index;
typedef class rgen_ral_shadow_reg_ftdr_seq;

class rgen_ral_shadow_reg extends rgen_ral_reg;
  protected rgen_ral_shadow_reg_index shadow_reg_indexes[$];

  extern function new(string name, int unsigned n_bits, int has_coverage);

  extern function void configure(
    uvm_object    cfg,
    uvm_reg_block blk_parent,
    uvm_reg_file  regfile_parent,
    int           indexes[$],
    string        hdl_path = ""
  );

  extern virtual function uvm_reg_frontdoor create_frontdoor();
  extern virtual function bit is_active();

  extern protected virtual function void configure_shadow_indexes();
  extern protected function void set_shadow_index(string reg_name, string field_name, uvm_reg_data_t value);
  extern protected virtual function void add_frontdoor_to_map(uvm_reg_map map);
endclass

function rgen_ral_shadow_reg::new(string name, int unsigned n_bits, int has_coverage);
  super.new(name, n_bits, has_coverage);
endfunction

function void rgen_ral_shadow_reg::configure(
  uvm_object    cfg,
  uvm_reg_block blk_parent,
  uvm_reg_file  regfile_parent,
  int           indexes[$],
  string        hdl_path
);
  super.configure(cfg, blk_parent, regfile_parent, indexes, hdl_path);
  configure_shadow_indexes();
endfunction

function uvm_reg_frontdoor rgen_ral_shadow_reg::create_frontdoor();
  rgen_ral_shadow_reg_ftdr_seq  fd  = new(shadow_reg_indexes);
  return fd;
endfunction

function bit rgen_ral_shadow_reg::is_active();
  foreach (shadow_reg_indexes[i]) begin
    if (!shadow_reg_indexes[i].is_matched()) begin
      return 0;
    end
  end
  return 1;
endfunction

function void rgen_ral_shadow_reg::configure_shadow_indexes();
endfunction

function void rgen_ral_shadow_reg::set_shadow_index(string reg_name, string field_name, uvm_reg_data_t value);
  rgen_ral_shadow_reg_index shadow_reg_index;
  shadow_reg_index  = new(this, reg_name, field_name, value);
  shadow_reg_indexes.push_back(shadow_reg_index);
endfunction

class rgen_ral_shadow_reg_index;
  protected rgen_ral_shadow_reg shadow_reg;
  protected reg_name            reg_name;
  protected field_name          field_name;
  protected uvm_reg_field       index_field;

  extern function new(
    rgen_ral_shadow_reg shadow_reg,
    string              reg_name,
    string              field_name,
    uvm_reg_data_t      value
  );

  extern virtual function bit is_matched();
  extern virtual task update(
    output  uvm_status_e      status,
    input   uvm_path_e        path      = UVM_DEFAULT_PATH,
    input   uvm_reg_map       map       = null,
    input   uvm_sequence_base parent    = null,
    input   int               prior     = -1,
    input   uvm_object        extension = null,
    input   string            fname     = "",
    input   int               lineno    = 0
  );

  extern protected virtual function uvm_reg_field get_index_field();
endclass

function rgen_ral_shadow_reg_index::new(
  rgen_ral_shadow_reg shadow_reg,
  string              reg_name,
  string              field_name,
  uvm_reg_data_t      value
);
  this.shadow_reg = shadow_reg;
  this.reg_name   = reg_name;
  this.field_name = field_name;
  this.value      = value;
endfunction

function bit rgen_ral_shadow_reg_index::is_matched();
  uvm_reg_field field = get_index_field();
  return (field.value == value) ? 1 : 0;
endfunction

task rgen_ral_shadow_reg_index::update(
  output  uvm_status_e      status,
  input   uvm_path_e        path,
  input   uvm_reg_map       map,
  input   uvm_sequence_base parent,
  input   int               prior,
  input   uvm_object        extension,
  input   string            fname,
  input   int               lineno
);
  uvm_reg_field field       = get_index_field();
  uvm_reg       parent_reg  = field.get_parent();
  field.set(value);
  parent_reg.update(status, path, map, parent, prior, extension, fname, lineno);
endtask

function uvm_reg_field rgen_ral_shadow_reg_index::get_index_field();
  if (index_field == null) begin
    uvm_reg_block parent_block  = shadow_reg.get_parent();
    uvm_reg       index_reg;

    index_reg = parent_block.get_reg_by_name(reg_name);
    if (index_reg == null) begin
      `uvm_fatal("rgen_ral_shadow_reg_index", $sformatf("Unable to locate index register: %s", reg_name))
      return;
    end

    index_field = index_reg.get_field_by_name(field_name);
    if (index_field == null) begin
      `uvm_fatal("rgen_ral_shadow_reg_index", $sformatf("Unable to locate index field: %s", field_name))
      return;
    end
  end
  return index_field;
endfunction

class rgen_ral_shadow_reg_ftdr_seq extends uvm_reg_frontdoor;
  protected rgen_ral_shadow_reg_index shadow_indexes[$];

  extern function new(ref rgen_ral_shadow_reg_index shadow_indexes[$]);

  extern virtual task body();
endclass

function rgen_ral_shadow_reg_ftdr_seq::new(ref rgen_ral_shadow_reg_index shadow_indexes[$]);
  super.new("rgen_ral_shadow_reg_ftdr_seq");
  foreach (shadow_indexes[i]) begin
    this.shadow_indexes.push_back(shadow_indexes[i]);
  end
endfunction

task rgen_ral_shadow_reg_ftdr_seq::body();
  foreach (shadow_indexes[i]) begin
    uvm_status_e  status;
    shadow_indexes[i].update(
      status,
      rw_info.path,
      rw_info.map,
      rw_info.parent,
      rw_info.prior,
      rw_info.extension,
      rw_info.fname,
      rw_info.lineno
    );
    if (status == UVM_NOT_OK) begin
      `uvm_warning("rgen_ral_shadow_reg_ftdr_seq", "Updating index field failed")
      rw_info = status;
      return;
    end
  end

  if (rw.kind == UVM_WRITE) begin
    rw_info.local_map.do_write(rw_info);
  end
  else begin
    rw_info.local_map.do_read(rw_info);
  end
endtask
`endif
