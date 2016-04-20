function automatic logic [DATA_WIDTH-1:0] get_write_mask(
  input [DATA_WIDTH/8-1:0]  strobe
);
  logic [DATA_WIDTH-1:0]  write_mask;
  for (int i = 0;i < $size(strobe);i++) begin
    write_mask[i*8+:8]  = {8{strobe[i]}};
  end
  return write_mask;
endfunction
