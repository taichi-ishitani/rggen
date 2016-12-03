`ifndef __RGGEN_RAL_MAP_SVH__
`define __RGGEN_RAL_MAP_SVH__
class rggen_ral_map extends uvm_reg_map;
  protected rggen_ral_indirect_reg  m_indirect_regs_by_offset[uvm_reg_addr_t][$];

  extern function new(string name = "rggen_ral_map");

  extern virtual function void add_reg(
    uvm_reg           rg,
    uvm_reg_addr_t    offset,
    string            rights    = "RW",
    bit               unmapped  = 0,
    uvm_reg_frontdoor frontdoor = null
  );
  extern virtual function void set_base_addr(uvm_reg_addr_t offset);
  extern virtual function void set_submap_offset(uvm_reg_map submap, uvm_reg_addr_t offset);

  extern virtual function uvm_reg get_reg_by_offset(uvm_reg_addr_t offset, bit read = 1);

  extern function void Xinit_indirect_reg_address_mapX();

  `uvm_object_utils(rggen_ral_map)
endclass

function rggen_ral_map::new(string name);
  super.new(name);
endfunction

function void rggen_ral_map::add_reg(
  uvm_reg           rg,
  uvm_reg_addr_t    offset,
  string            rights,
  bit               unmapped,
  uvm_reg_frontdoor frontdoor
);
  rggen_ral_reg           rggen_reg;
  rggen_ral_indirect_reg  rggen_indirect_reg;

  if ((frontdoor == null) && $cast(rggen_reg, rg)) begin
    frontdoor = rggen_reg.create_frontdoor();
  end
  if ($cast(rggen_indirect_reg, rg)) begin
    unmapped  = 1;
  end
  super.add_reg(rg, offset, rights, unmapped, frontdoor);
endfunction

function void rggen_ral_map::set_base_addr(uvm_reg_addr_t offset);
  uvm_reg_block parent_block  = get_parent();
  uvm_reg_map   parent_map    = get_parent_map();
  bit           locked        = parent_block.is_locked();
  super.set_base_addr(offset);
  if ((parent_map == null) && locked) begin
    Xinit_indirect_reg_address_mapX();
  end
endfunction

function void rggen_ral_map::set_submap_offset(uvm_reg_map submap, uvm_reg_addr_t offset);
  uvm_reg_block parent_block  = get_parent();
  bit           locked        = parent_block.is_locked();
  super.set_submap_offset(submap, offset);
  if ((submap != null) && locked) begin
    uvm_reg_map   root_map  = get_root_map();
    rggen_ral_map rggen_map;
    if ($cast(rggen_map, root_map)) begin
      rggen_map.Xinit_indirect_reg_address_mapX();
    end
  end
endfunction

function uvm_reg rggen_ral_map::get_reg_by_offset(uvm_reg_addr_t offset, bit read);
  uvm_reg       rg      = super.get_reg_by_offset(offset, read);
  uvm_reg_block parent  = get_parent();
  if ((rg == null) && parent.is_locked() && m_indirect_regs_by_offset.exists(offset)) begin
    foreach (m_indirect_regs_by_offset[offset][i]) begin
      if (m_indirect_regs_by_offset[offset][i].is_active()) begin
        rg  = m_indirect_regs_by_offset[offset][i];
        break;
      end
    end
  end
  return rg;
endfunction

function void rggen_ral_map::Xinit_indirect_reg_address_mapX();
  uvm_reg_map   top_map;
  rggen_ral_map top_rggen_map;
  uvm_reg_map   submaps[$];
  uvm_reg       regs[$];

  top_map = get_root_map();
  if (top_map == this) begin
    m_indirect_regs_by_offset.delete();
  end
  if (!$cast(top_rggen_map, top_map)) begin
    return;
  end

  get_submaps(submaps, UVM_NO_HIER);
  foreach (submaps[i]) begin
    rggen_ral_map rggen_map;
    if ($cast(rggen_map, submaps[i])) begin
      rggen_map.Xinit_indirect_reg_address_mapX();
    end
  end

  get_registers(regs, UVM_NO_HIER);
  foreach (regs[i]) begin
    rggen_ral_indirect_reg  indirect_reg;
    uvm_reg_map_info        map_info;

    if (!$cast(indirect_reg, regs[i])) begin
      continue;
    end

    map_info          = get_reg_map_info(indirect_reg);
    map_info.unmapped = 0;
    void'(get_physical_addresses(map_info.offset, 0, indirect_reg.get_n_bytes(), map_info.addr));
    foreach (map_info.addr[j]) begin
      top_rggen_map.m_indirect_regs_by_offset[map_info.addr[j]].push_back(indirect_reg);
    end
  end
endfunction
`endif
