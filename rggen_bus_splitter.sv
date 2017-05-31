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

  localparam  int STATUS_WIDTH  = $bits(rggen_status);

  logic [TOTAL_REGISTERS-1:0] select;
  logic [TOTAL_REGISTERS-1:0] ready;
  logic                       response_ready;
  logic                       register_selected;
  logic                       done;
  logic [DATA_WIDTH-1:0]      selected_read_data;
  rggen_status                selected_status;
  genvar                      g_i, g_j;

  generate for (g_i = 0;g_i < TOTAL_REGISTERS;++g_i) begin : g
    assign  register_if[g_i].request      = bus_if.request;
    assign  register_if[g_i].address      = bus_if.address;
    assign  register_if[g_i].direction    = bus_if.direction;
    assign  register_if[g_i].write_data   = bus_if.write_data;
    assign  register_if[g_i].write_strobe = bus_if.write_strobe;
    assign  select[g_i]                   = register_if[g_i].select;
    assign  ready[g_i]                    = register_if[g_i].ready;
  end endgenerate

  assign  bus_if.done       = done;
  assign  response_ready    = |ready;
  assign  register_selected = |select;
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      done              <= '0;
      bus_if.read_done  <= '0;
      bus_if.write_done <= '0;
      bus_if.read_data  <= '0;
      bus_if.status     <= RGGEN_OKAY;
    end
    else if (bus_if.request && (response_ready || (!register_selected)) && (!done)) begin
      done              <= '1;
      bus_if.read_done  <= (bus_if.direction == RGGEN_READ ) ? '1 : '0;
      bus_if.write_done <= (bus_if.direction == RGGEN_WRITE) ? '1 : '0;
      if (register_selected) begin
        bus_if.read_data  <= selected_read_data;
        bus_if.status     <= selected_status;
      end
      else begin
        bus_if.read_data  <= '0;
        bus_if.status     <= RGGEN_SLAVE_ERROR;
      end
    end
    else begin
      done              <= '0;
      bus_if.read_done  <= '0;
      bus_if.write_done <= '0;
      bus_if.read_data  <= '0;
      bus_if.status     <= RGGEN_OKAY;
    end
  end

  //  Response Selection
  generate if (1) begin : read_data_selection
    for (g_i = 0;g_i < DATA_WIDTH;++g_i) begin : g
      logic [TOTAL_REGISTERS-1:0] temp;
      assign  selected_read_data[g_i] = |temp;
      for (g_j = 0;g_j < TOTAL_REGISTERS;++g_j) begin : g
        assign  temp[g_j] = register_if[g_j].read_data[g_i] & register_if[g_j].select;
      end
    end
  end endgenerate

  generate if (1) begin : status_selection
    for (g_i = 0;g_i < STATUS_WIDTH;++g_i) begin : g
      logic [TOTAL_REGISTERS-1:0] temp;
      assign  selected_status[g_i]  = |temp;
      for (g_j = 0;g_j < TOTAL_REGISTERS;++g_j) begin : g
        assign  temp[g_j] = register_if[g_j].status[g_i] & register_if[g_j].select;
      end
    end
  end endgenerate
endmodule
