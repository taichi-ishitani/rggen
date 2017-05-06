module rggen_external_register #(
  parameter int                     ADDRESS_WIDTH = 16,
  parameter bit [ADDRESS_WIDTH-1:0] START_ADDRESS = '0,
  parameter bit [ADDRESS_WIDTH-1:0] END_ADDRESS   = '0,
  parameter int                     DATA_WIDTH    = 32
)(
  input                     clk,
  input                     rst_n,
  rggen_register_if.control register_control_if,
  rggen_register_if.data    register_data_if,
  rggen_bus_if.master       bus_if
);
  import  rggen_rtl_pkg::*;

  localparam  int EXTERNAL_SIZE           = END_ADDRESS - START_ADDRESS + 1;
  localparam  int EXTERNAL_ADDRESS_WIDTH  = $clog2(EXTERNAL_SIZE);

  logic                               address_match;
  logic                               request;
  logic [EXTERNAL_ADDRESS_WIDTH-1:0]  address;
  rggen_direction                     direction;
  logic [DATA_WIDTH-1:0]              write_data;
  logic [DATA_WIDTH/8-1:0]            write_strobe;
  logic                               access_done;

  rggen_default_register #(
    .ADDRESS_WIDTH  (ADDRESS_WIDTH  ),
    .START_ADDRESS  (START_ADDRESS  ),
    .END_ADDRESS    (END_ADDRESS    ),
    .DATA_WIDTH     (DATA_WIDTH     ),
    .INTERNAL_USE   (1              )
  ) u_register (register_control_if, address_match);

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      access_done <= '0;
    end
    else if (request && bus_if.done) begin
      access_done <= '1;
    end
    else begin
      access_done <= '0;
    end
  end

  //  Local -> External
  assign  bus_if.request      = request;
  assign  bus_if.address      = address;
  assign  bus_if.direction    = direction;
  assign  bus_if.write_data   = write_data;
  assign  bus_if.write_strobe = write_strobe;
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      request       <= '0;
      address       <= '0;
      direction     <= RGGEN_READ;
      write_data    <= '0;
      write_strobe  <= '0;
    end
    else if (request && bus_if.done) begin
      request       <= '0;
      address       <= '0;
      direction     <= RGGEN_READ;
      write_data    <= '0;
      write_strobe  <= '0;
    end
    else if (register_control_if.request && address_match && (!request) && (!access_done)) begin
      request       <= '1;
      address       <= calc_address(register_control_if.address);
      direction     <= register_control_if.direction;
      write_data    <= register_data_if.write_data;
      write_strobe  <= register_data_if.write_strobe;
    end
  end

  function automatic logic [EXTERNAL_ADDRESS_WIDTH-1:0] calc_address(input [ADDRESS_WIDTH-1:0] address);
    logic [ADDRESS_WIDTH-1:0] external_address;
    external_address  = address - START_ADDRESS;
    return external_address[EXTERNAL_ADDRESS_WIDTH-1:0];
  endfunction

  //  External -> Local
  assign  register_control_if.ready   = bus_if.done;
  assign  register_data_if.value      = bus_if.read_data;
  assign  register_data_if.read_data  = bus_if.read_data;
  assign  register_control_if.status  = bus_if.status;
endmodule
