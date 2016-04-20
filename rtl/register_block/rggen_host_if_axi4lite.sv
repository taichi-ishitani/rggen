module rggen_host_if_axi4lite #(
  parameter DATA_WIDTH          = 32,
  parameter HOST_ADDRESS_WIDTH  = 16,
  parameter LOCAL_ADDRESS_WIDTH = 16,
  parameter WRITE_PRIORITY      = 1
)(
  input                             clk,
  input                             rst_n,
  input                             i_awvalid,
  output                            o_awready,
  input   [HOST_ADDRESS_WIDTH-1:0]  i_awaddr,
  input   [2:0]                     i_awprot,
  input                             i_wvalid,
  output                            o_wready,
  input   [DATA_WIDTH-1:0]          i_wdata,
  input   [DATA_WIDTH/8-1:0]        i_wstrb,
  output                            o_bvalid,
  input                             i_bready,
  output  [1:0]                     o_bresp,
  input                             i_arvalid,
  output                            o_arready,
  input   [HOST_ADDRESS_WIDTH-1:0]  i_araddr,
  input   [2:0]                     i_arprot,
  output                            o_rvalid,
  input                             i_rready,
  output  [DATA_WIDTH-1:0]          o_rdata,
  output  [1:0]                     o_rresp,
  output                            o_command_valid,
  output                            o_write,
  output                            o_read,
  output  [LOCAL_ADDRESS_WIDTH-1:0] o_address,
  output  [DATA_WIDTH-1:0]          o_write_data,
  output  [DATA_WIDTH-1:0]          o_write_mask,
  input                             i_response_ready,
  input   [DATA_WIDTH-1:0]          i_read_data,
  input   [1:0]                     i_status
);
  `include "rggen_host_if_common.svh"

  typedef enum logic [5:0] {
    IDLE              = 6'b000001,
    WAIT_WDATA        = 6'b000010,
    WRITE_IN_PROGRESS = 6'b000100,
    WAIT_BRESP_READY  = 6'b001000,
    READ_IN_PROGRESS  = 6'b010000,
    WAIT_RDATA_READY  = 6'b100000
  } e_state;

  typedef enum logic [1:0] {
    OKAY    = 2'b00,
    EXOKAY  = 2'b01,
    SLVERR  = 2'b10,
    DECERR  = 2'b11
  } e_resp;

  function e_resp get_resp(logic [1:0] status);
    case (1'b1)
      status[0]:  return SLVERR;
      status[1]:  return EXOKAY;
      default:    return OKAY;
    endcase
  endfunction

  e_state                         state;
  logic                           awready;
  logic                           wready;
  logic                           bvalid;
  e_resp                          bresp;
  logic                           arready;
  logic                           rvalid;
  logic [DATA_WIDTH-1:0]          rdata;
  e_resp                          rresp;
  logic                           awack;
  logic                           wack;
  logic                           back;
  logic                           arack;
  logic                           rack;
  logic                           command_valid;
  logic                           local_done;
  logic [LOCAL_ADDRESS_WIDTH-1:0] address;
  logic [DATA_WIDTH-1:0]          write_data;
  logic [DATA_WIDTH-1:0]          write_mask;

//--------------------------------------------------------------
// State machine
//--------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= IDLE;
    end
    else begin
      unique case (state)
        IDLE: begin
          if (awack && wack) begin
            state <= WRITE_IN_PROGRESS;
          end
          else if (awack) begin
            state <= WAIT_WDATA;
          end
          else if (arack) begin
            state <= READ_IN_PROGRESS;
          end
        end
        WAIT_WDATA: begin
          if (wack) begin
            state <= WRITE_IN_PROGRESS;
          end
        end
        WRITE_IN_PROGRESS: begin
          if (local_done) begin
            state <= WAIT_BRESP_READY;
          end
        end
        WAIT_BRESP_READY: begin
          if (back) begin
            state <= IDLE;
          end
        end
        READ_IN_PROGRESS: begin
          if (local_done) begin
            state <= WAIT_RDATA_READY;
          end
        end
        WAIT_RDATA_READY: begin
          if (rack) begin
            state <= IDLE;
          end
        end
        default: begin
          state <= IDLE;
        end
      endcase
    end
  end

//--------------------------------------------------------------
// AXI4-Lite
//--------------------------------------------------------------
  assign  o_awready = awready;
  assign  o_wready  = wready;
  assign  o_bvalid  = bvalid;
  assign  o_bresp   = bresp;
  assign  o_arready = arready;
  assign  o_rvalid  = rvalid;
  assign  o_rdata   = rdata;
  assign  o_rresp   = rresp;

  assign  awack = i_awvalid & awready;
  assign  wack  = i_wvalid  & wready;
  assign  back  = bvalid    & i_bready;
  assign  arack = i_arvalid & arready;
  assign  rack  = rvalid    & i_rready;

  generate
    if (WRITE_PRIORITY) begin
      assign  awready = state[0];
      assign  wready  = (state[0] || state[1]) ? 1'b1 : 1'b0;
      assign  bvalid  = state[3];
      assign  arready = (state[0] && (!i_awvalid)) ? 1'b1 : 1'b0;
      assign  rvalid  = state[5];
    end
    else begin
      assign  awready = (state[0] && (!i_arvalid)) ? 1'b1 : 1'b0;
      assign  wready  = ((state[0] && (!i_arvalid)) || state[1]) ? 1'b1 : 1'b0;
      assign  bvalid  = state[3];
      assign  arready = state[0];
      assign  rvalid  = state[5];
    end
  endgenerate

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      bresp <= OKAY;
    end
    else if (state[2] && local_done) begin
      bresp <= get_resp(i_status);
    end
    else if (back) begin
      bresp <= OKAY;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rdata <= '0;
      rresp <= OKAY;
    end
    else if (state[4] && local_done) begin
      rdata <= i_read_data;
      rresp <= get_resp(i_status);
    end
    else if (rack) begin
      rdata <= '0;
      rresp <= OKAY;
    end
  end

//--------------------------------------------------------------
// Local bus
//--------------------------------------------------------------
  assign  o_command_valid = command_valid;
  assign  o_address       = address;
  assign  o_write         = state[2];
  assign  o_read          = state[4];
  assign  o_write_data    = write_data;
  assign  o_write_mask    = write_mask;

  assign  local_done  = command_valid & i_response_ready;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      command_valid <= 1'b0;
    end
    else if (wack || arack) begin
      command_valid <= 1'b1;
    end
    else if (local_done) begin
      command_valid <= 1'b0;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      address <= '0;
    end
    else if (awack) begin
      address <= i_awaddr[LOCAL_ADDRESS_WIDTH-1:0];
    end
    else if (arack) begin
      address <= i_araddr[LOCAL_ADDRESS_WIDTH-1:0];
    end
    else if (local_done) begin
      address <= '0;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      write_data  <= '0;
      write_mask  <= '0;
    end
    else if (wack) begin
      write_data  <= i_wdata;
      write_mask  <= get_write_mask(i_wstrb);
    end
    else if (local_done) begin
      write_data  <= '0;
      write_mask  <= '0;
    end
  end
endmodule
