`ifndef __RGGEN_RAL_MACROS_SVH__
`define __RGGEN_RAL_MACROS_SVH__

`define rggen_ral_create_field_model(handle, name, width, lsb, access, volatile, reset, has_reset) \
begin \
  handle  = new(name); \
  handle.configure(this.cfg, this, width, lsb, access, volatile, reset, has_reset, 1, 1); \
end

`define rggen_ral_create_reg_model(handle, name, array_index, offset_address, rights, unmapped) \
begin \
  handle  = new(name); \
  handle.configure(this.cfg, this, null, array_index); \
  default_map.add_reg(handle, offset_address, rights, unmapped); \
end

`define rggen_ral_create_block_model(handle, name, offset_address) \
begin \
  handle  = new(name); \
  handle.configure(this.cfg, this, ""); \
  default_map.add_submap(handle.default_map, offset_address); \
end

`endif
