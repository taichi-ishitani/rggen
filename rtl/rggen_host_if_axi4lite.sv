module rggen_host_if_axi4lite
  import  rggen_rtl_pkg::*;
#(
  parameter int             LOCAL_ADDRESS_WIDTH = 16,
  parameter int             DATA_WIDTH          = 32,
  parameter int             TOTAL_REGISTERS     = 1,
  parameter rggen_direction ACCESS_PRIORITY     = RGGEN_WRITE
)(
  input logic               clk,
  input logic               rst_n,
  rggen_axi4lite_if.slave   axi4lite_if,
  rggen_register_if.master  register_if[TOTAL_REGISTERS]
);
  typedef enum logic [4:0] {
    IDLE              = 5'b00001,
    WRITE_IN_PROGRESS = 5'b00010,
    WAIT_FOR_BREADY   = 5'b00100,
    READ_IN_PROGRESS  = 5'b01000,
    WAIT_FOR_RREADY   = 5'b10000
  } e_state;

  rggen_bus_if #(LOCAL_ADDRESS_WIDTH, DATA_WIDTH) bus_if();
  e_state                                         state;

//--------------------------------------------------------------
//  AXI4 Lite
//--------------------------------------------------------------
  logic                   write_request;
  logic                   valid_write_request;
  logic                   write_request_ack;
  logic                   read_request;
  logic                   valid_read_request;
  logic                   read_request_ack;
  logic [DATA_WIDTH-1:0]  read_data;
  rggen_status            status;

  assign  axi4lite_if.awready = write_request_ack;
  assign  axi4lite_if.wready  = write_request_ack;
  assign  axi4lite_if.bvalid  = state[2];
  assign  axi4lite_if.bresp   = status;
  assign  axi4lite_if.arready = read_request_ack;
  assign  axi4lite_if.rvalid  = state[4];
  assign  axi4lite_if.rdata   = read_data;
  assign  axi4lite_if.rresp   = status;

  assign  write_request = (axi4lite_if.awvalid && axi4lite_if.wvalid) ? '1 : '0;
  assign  read_request  = axi4lite_if.arvalid;

  generate if (ACCESS_PRIORITY == RGGEN_WRITE) begin
    assign  valid_write_request = (state[0]) ? write_request : '0;
    assign  valid_read_request  = (state[0] && (!valid_write_request)) ? read_request : '0;
  end
  else begin
    assign  valid_write_request = (state[0] && (!valid_read_request)) ? write_request : '0;
    assign  valid_read_request  = (state[0]) ? read_request : '0;
  end endgenerate

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      write_request_ack <= '0;
      read_request_ack  <= '0;
    end
    else begin
      write_request_ack <= valid_write_request;
      read_request_ack  <= valid_read_request;
    end
  end

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      read_data <= '0;
      status    <= RGGEN_OKAY;
    end
    else if ((state[1] || state[3]) && bus_if.done) begin
      read_data <= bus_if.read_data;
      status    <= bus_if.status;
    end
  end

//--------------------------------------------------------------
//  Bus IF
//--------------------------------------------------------------
  rggen_direction                 direction;
  logic [LOCAL_ADDRESS_WIDTH-1:0] address;
  logic [DATA_WIDTH-1:0]          write_data;
  logic [DATA_WIDTH/8-1:0]        write_strobe;

  assign  bus_if.request      = (state[1] || state[3]) ? '1 : '0;
  assign  bus_if.direction    = direction;
  assign  bus_if.address      = address;
  assign  bus_if.write_data   = write_data;
  assign  bus_if.write_strobe = write_strobe;

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      direction     <= RGGEN_READ;
      address       <= '0;
      write_data    <= '0;
      write_strobe  <= '0;
    end
    else if (state[0]) begin
      if (valid_write_request) begin
        direction     <= RGGEN_WRITE;
        address       <= axi4lite_if.awaddr;
        write_data    <= axi4lite_if.wdata;
        write_strobe  <= axi4lite_if.wstrb;
      end
      else if (valid_read_request) begin
        direction <= RGGEN_READ;
        address   <= axi4lite_if.araddr;
      end
    end
  end

  rggen_bus_splitter #(
    DATA_WIDTH, TOTAL_REGISTERS
  ) u_bus_splitter (
    clk, rst_n, bus_if, register_if
  );

//--------------------------------------------------------------
//  State Machine
//--------------------------------------------------------------
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      state <= IDLE;
    end
    else begin
      case (state)
        IDLE: begin
          if (valid_write_request) begin
            state <= WRITE_IN_PROGRESS;
          end
          else if (valid_read_request) begin
            state <= READ_IN_PROGRESS;
          end
        end
        WRITE_IN_PROGRESS: begin
          if (bus_if.write_done) begin
            state <= WAIT_FOR_BREADY;
          end
        end
        WAIT_FOR_BREADY: begin
          if (axi4lite_if.bready) begin
            state <= IDLE;
          end
        end
        READ_IN_PROGRESS: begin
          if (bus_if.read_done) begin
            state <= WAIT_FOR_RREADY;
          end
        end
        WAIT_FOR_RREADY: begin
          if (axi4lite_if.rready) begin
            state <= IDLE;
          end
        end
      endcase
    end
  end
endmodule
