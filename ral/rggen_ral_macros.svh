`ifndef __RGGEN_RAL_MACROS_SVH__
`define __RGGEN_RAL_MACROS_SVH__

`define rggen_ral_create_field_model(handle, name, width, lsb, access, volatile, reset, has_reset) \
begin \
  handle  = new(name); \
  handle.configure(this.cfg, this, width, lsb, access, volatile, reset, has_reset, 1, 1); \
end

`define rggen_ral_create_reg_model(handle, base_name, array_index, offset_address, rights, unmapped) \
begin \
  string  __instance_name   = base_name; \
  int     __array_index[$]  = array_index; \
  foreach (__array_index[__i]) begin \
    $sformat(__instance_name, "%s[%0d]", __instance_name, __array_index[__i]); \
  end \
  handle  = new(__instance_name); \
  handle.configure(this.cfg, this, null, array_index); \
  default_map.add_reg(handle, offset_address, rights, unmapped); \
end

`endif
