function automatic logic is_write_access(
  input command_valid,
  input select,
  input write
);
  return (command_valid && select && write) ? 1'b1 : 1'b0;
endfunction

function automatic logic [WIDTH-1:0] get_write_data(
  input [WIDTH-1:0] current_data,
  input [WIDTH-1:0] write_data,
  input [WIDTH-1:0] write_mask
);
  return (current_data & (~write_mask)) | (write_data & write_mask);
endfunction
