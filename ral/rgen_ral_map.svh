`ifndef __RGEN_RAL_MAP_SVH__
`define __RGEN_RAL_MAP_SVH__
class rgen_ral_map extends uvm_reg_map;
  protected rgen_ral_shadow_reg m_shadow_regs_by_offset[uvm_reg_addr_t][$];

  extern function new(string name = "rgen_ral_map");

  extern virtual function void add_reg(
    uvm_reg           rg,
    uvm_reg_addr_t    offset,
    string            right     = "RW",
    bit               unmapped  = 0,
    uvm_reg_frontdoor frontdoor = null
  );
  extern virtual function void set_base_addr(uvm_reg_addr_t offset);
  extern virtual function void set_submap_offset(uvm_reg_map submap, uvm_reg_addr_t offset);

  extern virtual function uvm_reg get_reg_by_offset(uvm_reg_addr_t offset, bit read = 1);

  extern function void Xinit_shadow_reg_address_mapX();

  `uvm_object_utils(rgen_ral_map)
endclass

function rgen_ral_map::new(string name);
  super.new(name);
endfunction

function void rgen_ral_map::add_reg(
  uvm_reg           rg,
  uvm_reg_addr_t    offset,
  string            right,
  bit               unmapped,
  uvm_reg_frontdoor frontdoor
);
  rgen_ral_reg        rgen_reg;
  rgen_ral_shadow_reg rgen_shadow_reg;

  if ((frontdoor == null) && $cast(rgen_reg, rg)) begin
    frontdoor = rgen_reg.create_frontdoor();
  end
  if ($cast(rgen_shadow_reg, rg)) begin
    unmapped  = 1;
  end
  super.add_reg(rg, offset, right, unmapped, frontdoor);
endfunction

function void rgen_ral_map::set_base_addr(uvm_reg_addr_t offset);
  uvm_reg_block parent_block  = get_parent();
  uvm_reg_map   parent_map    = get_parent_map();
  bit           locked        = parent_block.is_locked();
  super.set_base_addr(offset);
  if ((parent_map == null) && locked) begin
    Xinit_shadow_reg_address_mapX();
  end
endfunction

function void rgen_ral_map::set_submap_offset(uvm_reg_map submap, uvm_reg_addr_t offset);
  uvm_reg_block parent_block  = get_parent();
  bit           locked        = parent_block.is_locked();
  super.set_submap_offset(submap, offset);
  if ((submap != null) && locked) begin
    uvm_reg_map   root_map  = get_root_map();
    rgen_ral_map  rgen_map;
    if ($cast(rgen_map, root_map)) begin
      rgen_map.Xinit_shadow_reg_address_mapX();
    end
  end
endfunction

function uvm_reg rgen_ral_map::get_reg_by_offset(uvm_reg_addr_t offset, bit read);
  uvm_reg       rg      = super.get_reg_by_offset(offset, read);
  uvm_reg_block parent  = get_parent();
  if ((rg == null) && parent.is_locked() && m_shadow_regs_by_offset.exists(offset)) begin
    foreach (m_shadow_regs_by_offset[offset][i]) begin
      if (m_shadow_regs_by_offset[offset][i].is_active()) begin
        rg  = m_shadow_regs_by_offset[offset][i];
        break;
      end
    end
  end
  return rg;
endfunction

function void rgen_ral_map::Xinit_shadow_reg_address_mapX();
  uvm_reg_mem top_mem;
  uvm_reg_mem submaps[$];
  uvm_reg     regs[$];

  top_mem = get_root_map();
  if (top_mem == this) begin
    m_shadow_regs_by_offset.delete();
  end

  get_submaps(submaps, UVM_NO_HIER);
  foreach (submaps[i]) begin
    rgen_ral_map  rgen_map;
    if ($cast(rgen_map, submaps[i])) begin
      rgen_map.Xinit_shadow_reg_address_mapX();
    end
  end

  get_registers(regs, UVM_NO_HIER);
  foreach (regs[i]) begin
    rgen_ral_shadow_reg shadow_reg;
    uvm_reg_map_info    map_info;

    if (!$cast(shadow_reg, regs[i])) begin
      continue;
    end

    map_info  = get_reg_map_info(shadow_reg);
    void'(get_physical_addresses(map_info.offset, 0, shadow_reg.get_n_bytes(), map_info.addr));
    foreach (map_info.addr[j]) begin
      top_mem.m_shadow_regs_by_offset[map_info.addr[j]].push_back(shadow_reg);
    end
  end
endfunction
`endif
