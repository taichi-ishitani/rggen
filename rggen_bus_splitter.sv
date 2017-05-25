module rggen_bus_splitter #(
  parameter int DATA_WIDTH      = 32,
  parameter int TOTAL_REGISTERS = 1
)(
  input                     clk,
  input                     rst_n,
  rggen_bus_if.slave        bus_if,
  rggen_register_if.master  register_if[TOTAL_REGISTERS]
);
  import  rggen_rtl_pkg::*;

  localparam  INDEX_WIDTH   = $clog2(TOTAL_REGISTERS+1);

  typedef struct packed {
    logic [DATA_WIDTH-1:0]  read_data;
    rggen_status            status;
  } s_response;

  logic [TOTAL_REGISTERS:0]   select;
  logic [TOTAL_REGISTERS:0]   ready;
  s_response                  response[TOTAL_REGISTERS+1];
  logic                       response_ready;
  logic                       no_register_selected;
  logic                       done;
  logic                       read_done;
  logic                       write_done;
  s_response                  selected_response;
  genvar                      g_i;

  assign  bus_if.done       = done;
  assign  bus_if.read_done  = read_done;
  assign  bus_if.write_done = write_done;
  assign  bus_if.read_data  = selected_response.read_data;
  assign  bus_if.status     = selected_response.status;

  generate for (g_i = 0;g_i < TOTAL_REGISTERS;++g_i) begin : g
    assign  register_if[g_i].request      = bus_if.request;
    assign  register_if[g_i].address      = bus_if.address;
    assign  register_if[g_i].direction    = bus_if.direction;
    assign  register_if[g_i].write_data   = bus_if.write_data;
    assign  register_if[g_i].write_strobe = bus_if.write_strobe;
    assign  select[g_i]                   = register_if[g_i].select;
    assign  ready[g_i]                    = register_if[g_i].ready;
    assign  response[g_i].read_data       = register_if[g_i].read_data;
    assign  response[g_i].status          = register_if[g_i].status;
  end endgenerate

  //  dummy response
  assign  no_register_selected      = ~|select[TOTAL_REGISTERS-1:0];
  assign  select[TOTAL_REGISTERS]   = no_register_selected;
  assign  ready[TOTAL_REGISTERS]    = no_register_selected;
  assign  response[TOTAL_REGISTERS] = '{read_data: '0, status: RGGEN_SLAVE_ERROR};

  assign  response_ready  = |ready;
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      done              <= '0;
      read_done         <= '0;
      write_done        <= '0;
      selected_response <= '{read_data: '0, status: RGGEN_OKAY};
    end
    else if (bus_if.request && response_ready && (!done)) begin
      done              <= '1;
      write_done        <= (bus_if.direction == RGGEN_WRITE) ? '1 : '0;
      read_done         <= (bus_if.direction == RGGEN_READ ) ? '1 : '0;
      selected_response <= response[calc_index()];
    end
    else begin
      done              <= '0;
      read_done         <= '0;
      write_done        <= '0;
      selected_response <= '{read_data: '0, status: RGGEN_OKAY};
    end
  end

  function automatic logic [INDEX_WIDTH-1:0] calc_index();
    logic [INDEX_WIDTH-1:0] index;
    for (int i = 0;i < INDEX_WIDTH;++i) begin
      logic [TOTAL_REGISTERS:0] temp;
      for (int j = 0;j <= TOTAL_REGISTERS;++j) begin
        temp[j] = j[i] & select[j];
      end
      index[i]  = |temp;
    end
    return index;
  endfunction
endmodule
