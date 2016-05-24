module rggen_host_if_apb #(
  parameter DATA_WIDTH          = 32,
  parameter HOST_ADDRESS_WIDTH  = 16,
  parameter LOCAL_ADDRESS_WIDTH = 16
)(
  input                             clk,
  input                             rst_n,
  input   [HOST_ADDRESS_WIDTH-1:0]  i_paddr,
  input   [2:0]                     i_pprot,
  input                             i_psel,
  input                             i_penable,
  input                             i_pwrite,
  input   [DATA_WIDTH-1:0]          i_pwdata,
  input   [DATA_WIDTH/8-1:0]        i_pstrb,
  output                            o_pready,
  output  [DATA_WIDTH-1:0]          o_prdata,
  output                            o_pslverr,
  output                            o_command_valid,
  output                            o_write,
  output                            o_read,
  output  [LOCAL_ADDRESS_WIDTH-1:0] o_address,
  output  [DATA_WIDTH/8-1:0]        o_strobe,
  output  [DATA_WIDTH-1:0]          o_write_data,
  output  [DATA_WIDTH-1:0]          o_write_mask,
  input                             i_response_ready,
  input   [DATA_WIDTH-1:0]          i_read_data,
  input   [1:0]                     i_status
);
  `include "rggen_host_if_common.svh"

  assign  o_pready  = i_response_ready;
  assign  o_prdata  = i_read_data;
  assign  o_pslverr = i_status[0];

  assign  o_command_valid = i_psel;
  assign  o_write         = i_pwrite;
  assign  o_read          = ~i_pwrite;
  assign  o_address       = i_paddr[LOCAL_ADDRESS_WIDTH-1:0];
  assign  o_strobe        = i_pstrb;
  assign  o_write_data    = i_pwdata;
  assign  o_write_mask    = get_write_mask(i_pstrb);
endmodule
