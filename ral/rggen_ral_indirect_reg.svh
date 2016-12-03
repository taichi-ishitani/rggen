`ifndef __RGGEN_RAL_INDIRECT_REG_SVH__
`define __RGGEN_RAL_INDIRECT_REG_SVH__
typedef class rggen_ral_indirect_reg_index;
typedef class rggen_ral_indirect_reg_ftdr_seq;

class rggen_ral_indirect_reg extends rggen_ral_reg;
  protected rggen_ral_indirect_reg_index  indirect_reg_indexes[$];

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

  extern protected virtual function void configure_indirect_indexes();
  extern protected function void set_indirect_index(string reg_name, string field_name, uvm_reg_data_t value);
endclass

function rggen_ral_indirect_reg::new(string name, int unsigned n_bits, int has_coverage);
  super.new(name, n_bits, has_coverage);
endfunction

function void rggen_ral_indirect_reg::configure(
  uvm_object    cfg,
  uvm_reg_block blk_parent,
  uvm_reg_file  regfile_parent,
  int           indexes[$],
  string        hdl_path
);
  super.configure(cfg, blk_parent, regfile_parent, indexes, hdl_path);
  configure_indirect_indexes();
endfunction

function uvm_reg_frontdoor rggen_ral_indirect_reg::create_frontdoor();
  rggen_ral_indirect_reg_ftdr_seq fd  = new(indirect_reg_indexes);
  return fd;
endfunction

function bit rggen_ral_indirect_reg::is_active();
  foreach (indirect_reg_indexes[i]) begin
    if (!indirect_reg_indexes[i].is_matched()) begin
      return 0;
    end
  end
  return 1;
endfunction

function void rggen_ral_indirect_reg::configure_indirect_indexes();
endfunction

function void rggen_ral_indirect_reg::set_indirect_index(string reg_name, string field_name, uvm_reg_data_t value);
  rggen_ral_indirect_reg_index indirect_reg_index;
  indirect_reg_index  = new(this, reg_name, field_name, value);
  indirect_reg_indexes.push_back(indirect_reg_index);
endfunction

class rggen_ral_indirect_reg_index;
  protected rggen_ral_indirect_reg  indirect_reg;
  protected string                  reg_name;
  protected string                  field_name;
  protected uvm_reg_data_t          value;
  protected uvm_reg                 index_reg;
  protected uvm_reg_field           index_field;

  extern function new(
    rggen_ral_indirect_reg  indirect_reg,
    string                  reg_name,
    string                  field_name,
    uvm_reg_data_t          value
  );

  extern virtual function bit is_matched();
  extern virtual function void set(string fname = "", int lineno = 0);
  extern virtual function uvm_reg get_index_reg();
  extern virtual function uvm_reg_field get_index_field();
endclass

function rggen_ral_indirect_reg_index::new(
  rggen_ral_indirect_reg  indirect_reg,
  string                  reg_name,
  string                  field_name,
  uvm_reg_data_t          value
);
  this.indirect_reg = indirect_reg;
  this.reg_name     = reg_name;
  this.field_name   = field_name;
  this.value        = value;
endfunction

function bit rggen_ral_indirect_reg_index::is_matched();
  void'(get_index_field());
  return (index_field.value == value) ? 1 : 0;
endfunction

function void rggen_ral_indirect_reg_index::set(string fname = "", int lineno = 0);
  void'(get_index_field());
  index_field.set(value, fname, lineno);
endfunction

function uvm_reg rggen_ral_indirect_reg_index::get_index_reg();
  if (index_reg == null) begin
    uvm_reg_block parent_block;
    parent_block  = indirect_reg.get_parent();
    index_reg     = parent_block.get_reg_by_name(reg_name);
    if (index_reg == null) begin
      `uvm_fatal("rggen_ral_indirect_reg_index", $sformatf("Unable to locate index register: %s", reg_name))
      return null;
    end
  end
  return index_reg;
endfunction

function uvm_reg_field rggen_ral_indirect_reg_index::get_index_field();
  if (index_field == null) begin
    void'(get_index_reg());
    index_field = index_reg.get_field_by_name(field_name);
    if (index_field == null) begin
      `uvm_fatal("rggen_ral_indirect_reg_index", $sformatf("Unable to locate index field: %s", field_name))
      return null;
    end
  end
  return index_field;
endfunction

class rggen_ral_indirect_reg_ftdr_seq extends uvm_reg_frontdoor;
  protected rggen_ral_indirect_reg_index  indirect_indexes[$];
  protected bit                           index_regs[uvm_reg];

  extern function new(ref rggen_ral_indirect_reg_index indirect_indexes[$]);

  extern virtual task body();
  extern task update_index_regs(ref uvm_status_e status);
endclass

function rggen_ral_indirect_reg_ftdr_seq::new(ref rggen_ral_indirect_reg_index indirect_indexes[$]);
  super.new("rggen_ral_indirect_reg_ftdr_seq");
  foreach (indirect_indexes[i]) begin
    this.indirect_indexes.push_back(indirect_indexes[i]);
  end
endfunction

task rggen_ral_indirect_reg_ftdr_seq::body();
  uvm_status_e  status;
  update_index_regs(status);
  if (status == UVM_NOT_OK) begin
    `uvm_warning("rggen_ral_indirect_reg_ftdr_seq", "Updating index registers failed")
    rw_info.status  = status;
    return;
  end
  if (rw_info.kind == UVM_WRITE) begin
    rw_info.local_map.do_write(rw_info);
  end
  else begin
    rw_info.local_map.do_read(rw_info);
  end
endtask

task rggen_ral_indirect_reg_ftdr_seq::update_index_regs(ref uvm_status_e status);
  if (index_regs.size() == 0) begin
    foreach (indirect_indexes[i]) begin
      uvm_reg index_reg = indirect_indexes[i].get_index_reg();
      if (!index_regs.exists(index_reg)) begin
        index_regs[index_reg] = 1;
      end
    end
  end
  foreach (indirect_indexes[i]) begin
    indirect_indexes[i].set(rw_info.fname, rw_info.lineno);
  end
  foreach (index_regs[index_reg]) begin
    index_reg.update(
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
      return;
    end
  end
endtask
`endif
