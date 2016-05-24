module rggen_bus_exporter #(
  parameter DATA_WIDTH              = 32,
  parameter LOCAL_ADDRESS_WIDTH     = 16,
  parameter EXTERNAL_ADDRESS_WIDTH  = 8,
  parameter START_ADDRESS           = 16'h0000
)(
  input                                 clk,
  input                                 rst_n,
  input                                 i_valid,
  input                                 i_select,
  input                                 i_write,
  input                                 i_read,
  input   [LOCAL_ADDRESS_WIDTH-1:0]     i_address,
  input   [DATA_WIDTH/8-1:0]            i_strobe,
  input   [DATA_WIDTH-1:0]              i_write_data,
  output                                o_ready,
  output  [DATA_WIDTH-1:0]              o_read_data,
  output  [1:0]                         o_status,
  output                                o_valid,
  output                                o_write,
  output                                o_read,
  output  [EXTERNAL_ADDRESS_WIDTH-1:0]  o_address,
  output  [DATA_WIDTH/8-1:0]            o_strobe,
  output  [DATA_WIDTH-1:0]              o_write_data,
  input                                 i_ready,
  input   [DATA_WIDTH-1:0]              i_read_data,
  input   [1:0]                         i_status
);
  logic                               access_done;
  logic                               valid;
  logic                               write;
  logic                               read;
  logic [EXTERNAL_ADDRESS_WIDTH-1:0]  address;
  logic [DATA_WIDTH/8-1:0]            strobe;
  logic [DATA_WIDTH-1:0]              write_data;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      access_done <= 1'b0;
    end
    else if (valid && i_ready) begin
      access_done <= 1'b1;
    end
    else begin
      access_done <= 1'b0;
    end
  end

  //  Internal -> External
  assign  o_valid       = valid;
  assign  o_write       = write;
  assign  o_read        = read;
  assign  o_address     = address;
  assign  o_strobe      = strobe;
  assign  o_write_data  = write_data;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      valid       <= 1'b0;
      write       <= 1'b0;
      read        <= 1'b0;
      address     <= '0;
      strobe      <= '0;
      write_data  <= '0;
    end
    else if (valid && i_ready) begin
      valid       <= 1'b0;
      write       <= 1'b0;
      read        <= 1'b0;
      address     <= '0;
      strobe      <= '0;
      write_data  <= '0;
    end
    else if (i_valid && i_select && (!valid) && (!access_done)) begin
      valid       <= 1'b1;
      write       <= i_write;
      read        <= i_read;
      address     <= calc_address(i_address);
      strobe      <= i_strobe;
      write_data  <= i_write_data;
    end
  end

  function automatic logic [EXTERNAL_ADDRESS_WIDTH-1:0] calc_address(
    input [LOCAL_ADDRESS_WIDTH-1:0] address
  );
    logic [LOCAL_ADDRESS_WIDTH-1:0] external_address;
    external_address  = address - START_ADDRESS;
    return external_address[EXTERNAL_ADDRESS_WIDTH-1:0];
  endfunction

  //  External -> Internal
  assign  o_ready     = i_ready;
  assign  o_read_data = i_read_data;
  assign  o_status    = i_status;
endmodule
