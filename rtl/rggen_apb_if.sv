interface rggen_apb_if #(
  parameter int ADDRESS_WIDTH = 16,
  parameter int DATA_WIDTH    = 32
)();
  logic                     psel;
  logic                     penable;
  logic [ADDRESS_WIDTH-1:0] paddr;
  logic                     pwrite;
  logic [DATA_WIDTH-1:0]    pwdata;
  logic [DATA_WIDTH/8-1:0]  pstrb;
  logic                     pready;
  logic [DATA_WIDTH-1:0]    prdata;
  logic                     pslverr;

  modport master (
    output  psel,
    output  penable,
    output  paddr,
    output  pwrite,
    output  pwdata,
    output  pstrb,
    input   pready,
    input   prdata,
    input   pslverr
  );

  modport slave (
    input   psel,
    input   penable,
    input   paddr,
    input   pwrite,
    input   pwdata,
    input   pstrb,
    output  pready,
    output  prdata,
    output  pslverr
  );
endinterface
